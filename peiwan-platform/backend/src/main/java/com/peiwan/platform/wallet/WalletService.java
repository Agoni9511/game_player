package com.peiwan.platform.wallet;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.peiwan.platform.persistence.entity.MemberLevelEntity;
import com.peiwan.platform.persistence.entity.RechargeOrderEntity;
import com.peiwan.platform.persistence.entity.RechargePlanEntity;
import com.peiwan.platform.persistence.entity.UserMemberEntity;
import com.peiwan.platform.persistence.entity.WalletAccountEntity;
import com.peiwan.platform.persistence.entity.WalletTransactionEntity;
import com.peiwan.platform.persistence.entity.TradeOrderEntity;
import com.peiwan.platform.persistence.entity.OrderPaymentEntity;
import com.peiwan.platform.persistence.mapper.MemberLevelMapper;
import com.peiwan.platform.persistence.mapper.RechargeOrderMapper;
import com.peiwan.platform.persistence.mapper.RechargePlanMapper;
import com.peiwan.platform.persistence.mapper.UserMemberMapper;
import com.peiwan.platform.persistence.mapper.WalletAccountMapper;
import com.peiwan.platform.persistence.mapper.WalletDataMapper;
import com.peiwan.platform.persistence.mapper.WalletTransactionMapper;
import com.peiwan.platform.persistence.mapper.TradeOrderMapper;
import com.peiwan.platform.persistence.mapper.OrderPaymentMapper;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

@Service
public class WalletService {
  private final WalletAccountMapper wallets;
  private final RechargePlanMapper plans;
  private final RechargeOrderMapper recharges;
  private final WalletTransactionMapper transactions;
  private final UserMemberMapper members;
  private final MemberLevelMapper memberLevels;
  private final WalletDataMapper data;
  private final TradeOrderMapper tradeOrders;
  private final OrderPaymentMapper tradePayments;

  public WalletService(
    WalletAccountMapper wallets,
    RechargePlanMapper plans,
    RechargeOrderMapper recharges,
    WalletTransactionMapper transactions,
    UserMemberMapper members,
    MemberLevelMapper memberLevels,
    WalletDataMapper data,
    TradeOrderMapper tradeOrders,
    OrderPaymentMapper tradePayments
  ) {
    this.wallets = wallets;
    this.plans = plans;
    this.recharges = recharges;
    this.transactions = transactions;
    this.members = members;
    this.memberLevels = memberLevels;
    this.data = data;
    this.tradeOrders = tradeOrders;
    this.tradePayments = tradePayments;
  }

  public Map<String, Object> summary(long uid) {
    var wallet = ensureWallet(uid);
    return Map.of(
      "account",
      walletView(wallet),
      "member",
      Objects.requireNonNullElse(data.member(uid), Map.of())
    );
  }

  public List<Map<String, Object>> enabledPlans() {
    return plans.selectList(new QueryWrapper<RechargePlanEntity>().eq("enabled", true).orderByAsc("sort_no", "id"))
      .stream()
      .map(this::planView)
      .toList();
  }

  public Map<String, Object> transactionPage(long uid, int current, int size, String type) {
    current = Math.max(1, current);
    size = Math.min(100, Math.max(1, size));
    var result = data.transactions(new Page<>(current, size), uid, type);
    return Map.of("records", result.getRecords(), "current", current, "size", size, "total", result.getTotal());
  }

  @Transactional
  public Map<String, Object> simulateRecharge(long uid, long planId, String requestNo) {
    if (requestNo == null || requestNo.isBlank() || requestNo.length() > 64) {
      throw new IllegalArgumentException("请求流水号不能为空且不能超过64位");
    }
    requestNo = requestNo.trim();
    var existing = findRecharge(uid, requestNo);
    if (existing != null) return rechargeView(existing, true);

    var plan = plans.selectById(planId);
    if (plan == null || !Boolean.TRUE.equals(plan.enabled)) {
      throw new IllegalArgumentException("充值套餐不存在或已停用");
    }

    ensureWallet(uid);
    var locked = data.lockUserWallet(uid);
    if (locked == null) throw new IllegalArgumentException("钱包创建失败");

    existing = findRecharge(uid, requestNo);
    if (existing != null) return rechargeView(existing, true);

    long accountId = ((Number) locked.get("id")).longValue();
    BigDecimal beforeCash = (BigDecimal) locked.get("cash_balance");
    BigDecimal beforeBonus = (BigDecimal) locked.get("bonus_balance");
    String rechargeNo = "RC" +
      LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) +
      UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase(Locale.ROOT);

    var order = new RechargeOrderEntity();
    var trade = new TradeOrderEntity();
    trade.orderNo = rechargeNo;
    trade.customerId = uid;
    trade.businessType = "WALLET_RECHARGE";
    trade.tradeStatus = "COMPLETED";
    trade.title = plan.planName;
    trade.totalAmount = plan.rechargeAmount;
    trade.discountAmount = BigDecimal.ZERO;
    trade.payableAmount = plan.rechargeAmount;
    trade.paidAmount = plan.rechargeAmount;
    trade.refundedAmount = BigDecimal.ZERO;
    trade.paymentStatus = "PAID";
    trade.refundStatus = "NONE";
    trade.paidAt = LocalDateTime.now();
    trade.completedAt = trade.paidAt;
    trade.createdBy = uid;
    tradeOrders.insert(trade);
    order.tradeOrderId = trade.id;
    order.rechargeNo = rechargeNo;
    order.requestNo = requestNo;
    order.userId = uid;
    order.planId = plan.id;
    order.rechargeAmount = plan.rechargeAmount;
    order.bonusAmount = plan.bonusAmount;
    order.rechargeStatus = "PAID";
    order.paidAt = LocalDateTime.now();
    recharges.insert(order);

    var payment = new OrderPaymentEntity();
    payment.paymentNo = "RCP" + rechargeNo;
    payment.requestNo = requestNo;
    payment.orderId = trade.id;
    payment.userId = uid;
    payment.paymentChannel = "MOCK_RECHARGE";
    payment.paymentStatus = "PAID";
    payment.payableAmount = plan.rechargeAmount;
    payment.cashAmount = plan.rechargeAmount;
    payment.bonusAmount = BigDecimal.ZERO;
    payment.refundedCashAmount = BigDecimal.ZERO;
    payment.refundedBonusAmount = BigDecimal.ZERO;
    payment.paidAt = order.paidAt;
    tradePayments.insert(payment);

    data.creditRecharge(accountId, plan.rechargeAmount, plan.bonusAmount);
    addTransaction(accountId, uid, "CASH", rechargeNo, plan.rechargeAmount, beforeCash, beforeCash.add(plan.rechargeAmount), "模拟充值");
    if (plan.bonusAmount.signum() > 0) {
      addTransaction(accountId, uid, "BONUS", rechargeNo, plan.bonusAmount, beforeBonus, beforeBonus.add(plan.bonusAmount), "充值赠送");
    }
    upgradeMember(uid, plan.rechargeAmount);
    return rechargeView(order, false);
  }

  public Map<String, Object> adminPlans(int current, int size) {
    current = Math.max(1, current);
    size = Math.min(100, Math.max(1, size));
    var result = plans.selectPage(new Page<>(current, size), new QueryWrapper<RechargePlanEntity>().orderByAsc("sort_no", "id"));
    return Map.of(
      "records",
      result.getRecords().stream().map(this::planView).toList(),
      "current",
      current,
      "size",
      size,
      "total",
      result.getTotal()
    );
  }

  public long savePlan(Long id, PlanCommand command) {
    if (command.planCode() == null || command.planCode().isBlank() || command.planName() == null || command.planName().isBlank()) {
      throw new IllegalArgumentException("套餐编码和名称不能为空");
    }
    if (command.rechargeAmount() == null || command.rechargeAmount().signum() <= 0 || command.bonusAmount() == null || command.bonusAmount().signum() < 0) {
      throw new IllegalArgumentException("充值金额必须大于0，赠送金额不能小于0");
    }

    try {
      var plan = id == null ? new RechargePlanEntity() : requiredPlan(id);
      plan.planCode = command.planCode().trim().toUpperCase(Locale.ROOT);
      plan.planName = command.planName().trim();
      plan.rechargeAmount = command.rechargeAmount();
      plan.bonusAmount = command.bonusAmount();
      plan.memberDays = null;
      plan.sortNo = command.sortNo();
      plan.enabled = command.enabled();
      plan.updatedAt = LocalDateTime.now();
      if (id == null) plans.insert(plan);
      else plans.updateById(plan);
      return plan.id;
    } catch (DuplicateKeyException e) {
      throw new IllegalArgumentException("充值套餐编码已存在");
    }
  }

  public void status(long id, boolean enabled) {
    var plan = requiredPlan(id);
    plan.enabled = enabled;
    plan.updatedAt = LocalDateTime.now();
    plans.updateById(plan);
  }

  public Map<String, Object> memberLevelPage(int current, int size, String keyword, Boolean enabled) {
    current = Math.max(1, current);
    size = Math.min(100, Math.max(1, size));
    var query = new QueryWrapper<MemberLevelEntity>();
    if (keyword != null && !keyword.isBlank()) {
      query.and(q ->
        q.like("level_name", keyword.trim())
          .or()
          .like("level_code", keyword.trim())
      );
    }
    if (enabled != null) query.eq("enabled", enabled);
    query.orderByAsc("level_no", "sort_no", "id");
    var result = memberLevels.selectPage(new Page<>(current, size), query);
    return Map.of(
      "records",
      result.getRecords().stream().map(this::memberLevelView).toList(),
      "current",
      current,
      "size",
      size,
      "total",
      result.getTotal()
    );
  }

  @Transactional
  public long saveMemberLevel(Long id, MemberLevelCommand command) {
    validateMemberLevel(command);
    try {
      var level = id == null ? new MemberLevelEntity() : requiredMemberLevel(id);
      level.levelCode = command.levelCode().trim().toUpperCase(Locale.ROOT);
      level.levelName = command.levelName().trim();
      level.levelNo = command.levelNo();
      level.discountRate = BigDecimal.ONE;
      level.minRechargeAmount = command.minRechargeAmount();
      level.benefitDescription = blankToNull(command.benefitDescription());
      level.sortNo = command.sortNo();
      level.enabled = command.enabled();
      level.updatedAt = LocalDateTime.now();
      if (id == null) memberLevels.insert(level);
      else memberLevels.updateById(level);
      recalculateMembers();
      return level.id;
    } catch (DuplicateKeyException e) {
      throw new IllegalArgumentException("会员等级编码或等级序号已存在");
    }
  }

  @Transactional
  public void setMemberLevelStatus(long id, boolean enabled) {
    var level = requiredMemberLevel(id);
    level.enabled = enabled;
    level.updatedAt = LocalDateTime.now();
    memberLevels.updateById(level);
    recalculateMembers();
  }

  @Transactional
  public void deleteMemberLevel(long id) {
    requiredMemberLevel(id);
    if (members.selectCount(new QueryWrapper<UserMemberEntity>().eq("level_id", id)) > 0) throw new IllegalArgumentException("该会员身份已授予用户，不能删除");
    memberLevels.deleteById(id);
  }

  private void validateMemberLevel(MemberLevelCommand command) {
    if (command.levelCode() == null || command.levelCode().isBlank()) throw new IllegalArgumentException("会员编码不能为空");
    if (!command.levelCode().trim().toUpperCase(Locale.ROOT).matches("[A-Z0-9_]{2,32}")) {
      throw new IllegalArgumentException("会员编码只能包含大写字母、数字和下划线");
    }
    if (command.levelName() == null || command.levelName().isBlank()) throw new IllegalArgumentException("会员名称不能为空");
    if (command.levelNo() == null || command.levelNo() < 0) throw new IllegalArgumentException("等级序号不能小于0");
    if (command.minRechargeAmount() == null || command.minRechargeAmount().signum() < 0) throw new IllegalArgumentException("累计充值门槛不能小于0");
  }

  private WalletAccountEntity ensureWallet(long uid) {
    var wallet = wallets.selectOne(new QueryWrapper<WalletAccountEntity>().eq("owner_type", "USER").eq("owner_id", uid));
    if (wallet != null) return wallet;
    try {
      wallet = new WalletAccountEntity();
      wallet.ownerType = "USER";
      wallet.ownerId = uid;
      wallet.cashBalance = BigDecimal.ZERO;
      wallet.bonusBalance = BigDecimal.ZERO;
      wallet.frozenBalance = BigDecimal.ZERO;
      wallet.version = 0L;
      wallets.insert(wallet);
      return wallet;
    } catch (DuplicateKeyException e) {
      return wallets.selectOne(new QueryWrapper<WalletAccountEntity>().eq("owner_type", "USER").eq("owner_id", uid));
    }
  }

  private void upgradeMember(long uid, BigDecimal amount) {
    var member = members.selectOne(new QueryWrapper<UserMemberEntity>().eq("user_id", uid));
    var total = Objects.requireNonNullElse(member == null ? null : member.totalRechargeAmount, BigDecimal.ZERO).add(amount);
    applyMemberLevel(uid, total, member);
  }

  private void applyMemberLevel(long uid, BigDecimal total, UserMemberEntity member) {
    var now = LocalDateTime.now();
    var matchedLevel = data.matchedLevel(total);
    if (member == null) {
      if (matchedLevel == null) return;
      member = new UserMemberEntity();
      member.userId = uid;
      member.startedAt = now;
      member.createdAt = now;
      member.growthValue = 0L;
      member.totalRechargeAmount = BigDecimal.ZERO;
    }
    member.levelId = matchedLevel == null ? member.levelId : ((Number) matchedLevel.get("id")).longValue();
    if (member.startedAt == null) member.startedAt = now;
    member.expiredAt = null;
    member.totalRechargeAmount = total;
    member.growthValue = total.longValue();
    member.enabled = matchedLevel != null;
    member.updatedAt = now;
    if (member.id == null) members.insert(member);
    else members.updateById(member);
  }

  @Transactional
  public void refreshMembership(long uid) {
    var member = members.selectOne(new QueryWrapper<UserMemberEntity>().eq("user_id", uid));
    if (member != null) applyMemberLevel(uid, Objects.requireNonNullElse(member.totalRechargeAmount, BigDecimal.ZERO), member);
  }

  private void recalculateMembers() {
    for (var member : members.selectList(new QueryWrapper<UserMemberEntity>())) applyMemberLevel(member.userId, Objects.requireNonNullElse(member.totalRechargeAmount, BigDecimal.ZERO), member);
  }

  private void addTransaction(
    long account,
    long uid,
    String balance,
    String businessNo,
    BigDecimal amount,
    BigDecimal before,
    BigDecimal after,
    String remark
  ) {
    var transaction = new WalletTransactionEntity();
    transaction.transactionNo = "WT" + UUID.randomUUID().toString().replace("-", "").toUpperCase(Locale.ROOT);
    transaction.accountId = account;
    transaction.ownerType = "USER";
    transaction.ownerId = uid;
    transaction.balanceType = balance;
    transaction.direction = "IN";
    transaction.businessType = "RECHARGE";
    transaction.businessNo = businessNo;
    transaction.amount = amount;
    transaction.balanceBefore = before;
    transaction.balanceAfter = after;
    transaction.remark = remark;
    transactions.insert(transaction);
  }

  private RechargeOrderEntity findRecharge(long uid, String requestNo) {
    return recharges.selectOne(new QueryWrapper<RechargeOrderEntity>().eq("user_id", uid).eq("request_no", requestNo));
  }

  private Map<String, Object> rechargeView(RechargeOrderEntity order, boolean duplicated) {
    return Map.of(
      "rechargeNo",
      order.rechargeNo,
      "requestNo",
      order.requestNo,
      "cashAmount",
      order.rechargeAmount,
      "bonusAmount",
      order.bonusAmount,
      "duplicated",
      duplicated
    );
  }

  private RechargePlanEntity requiredPlan(long id) {
    var plan = plans.selectById(id);
    if (plan == null) throw new IllegalArgumentException("充值套餐不存在");
    return plan;
  }

  private MemberLevelEntity requiredMemberLevel(long id) {
    var level = memberLevels.selectById(id);
    if (level == null) throw new IllegalArgumentException("会员等级不存在");
    return level;
  }

  private Map<String, Object> walletView(WalletAccountEntity wallet) {
    return Map.of(
      "id",
      wallet.id,
      "cashBalance",
      wallet.cashBalance,
      "bonusBalance",
      wallet.bonusBalance,
      "frozenBalance",
      wallet.frozenBalance,
      "totalBalance",
      wallet.cashBalance.add(wallet.bonusBalance)
    );
  }

  private Map<String, Object> planView(RechargePlanEntity plan) {
    var view = new LinkedHashMap<String, Object>();
    view.put("id", plan.id);
    view.put("planCode", plan.planCode);
    view.put("planName", plan.planName);
    view.put("rechargeAmount", plan.rechargeAmount);
    view.put("bonusAmount", plan.bonusAmount);
    view.put("sortNo", plan.sortNo);
    view.put("enabled", plan.enabled);
    return view;
  }

  private Map<String, Object> memberLevelView(MemberLevelEntity level) {
    long memberCount = members.selectCount(new QueryWrapper<UserMemberEntity>().eq("level_id", level.id).eq("enabled", true));
    var view = new LinkedHashMap<String, Object>();
    view.put("id", level.id);
    view.put("levelCode", level.levelCode);
    view.put("levelName", level.levelName);
    view.put("levelNo", level.levelNo);
    view.put("minRechargeAmount", level.minRechargeAmount);
    view.put("benefitDescription", level.benefitDescription);
    view.put("sortNo", level.sortNo);
    view.put("enabled", level.enabled);
    view.put("memberCount", memberCount);
    return view;
  }

  private String blankToNull(String value) {
    if (value == null) return null;
    var trimmed = value.trim();
    return trimmed.isEmpty() ? null : trimmed;
  }

  public record PlanCommand(
    String planCode,
    String planName,
    BigDecimal rechargeAmount,
    BigDecimal bonusAmount,
    int sortNo,
    boolean enabled
  ) {}

  public record MemberLevelCommand(
    String levelCode,
    String levelName,
    Integer levelNo,
    BigDecimal minRechargeAmount,
    String benefitDescription,
    int sortNo,
    boolean enabled
  ) {}
}
