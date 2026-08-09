package com.peiwan.platform.player;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.peiwan.platform.persistence.entity.GameEntity;
import com.peiwan.platform.persistence.entity.GamePositionEntity;
import com.peiwan.platform.persistence.entity.PlayerAuditEntity;
import com.peiwan.platform.persistence.entity.PlayerEntity;
import com.peiwan.platform.persistence.entity.PlayerProfileDraftEntity;
import com.peiwan.platform.persistence.entity.PlayerTagEntity;
import com.peiwan.platform.persistence.mapper.GameMapper;
import com.peiwan.platform.persistence.mapper.GamePositionMapper;
import com.peiwan.platform.persistence.mapper.PlayerAuditMapper;
import com.peiwan.platform.persistence.mapper.PlayerMapper;
import com.peiwan.platform.persistence.mapper.PlayerProfileDraftMapper;
import com.peiwan.platform.persistence.mapper.PlayerTagMapper;
import com.peiwan.platform.persistence.mapper.SystemUserMapper;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PlayerProfileDraftService {
  private final PlayerProfileDraftMapper drafts;
  private final PlayerMapper players;
  private final PlayerTagMapper tags;
  private final GameMapper games;
  private final GamePositionMapper positions;
  private final PlayerAuditMapper audits;
  private final PlayerService playerService;
  private final SystemUserMapper users;
  private final ObjectMapper json;

  public PlayerProfileDraftService(
      PlayerProfileDraftMapper drafts,
      PlayerMapper players,
      PlayerTagMapper tags,
      GameMapper games,
      GamePositionMapper positions,
      PlayerAuditMapper audits,
      PlayerService playerService,
      SystemUserMapper users,
      ObjectMapper json) {
    this.drafts = drafts;
    this.players = players;
    this.tags = tags;
    this.games = games;
    this.positions = positions;
    this.audits = audits;
    this.playerService = playerService;
    this.users = users;
    this.json = json;
  }

  public Map<String, Object> ownProfile(long userId) {
    var player = ownPlayer(userId);
    var draft = draftByPlayer(player.id);
    var out = new LinkedHashMap<String, Object>();
    var profile = new LinkedHashMap<>(playerService.player(player.id));
    var user = users.selectById(userId);
    profile.put("loginAccount", user == null ? "" : user.username);
    out.put("profile", profile);
    out.put("draft", draft == null ? null : selfCommand(readCommand(draft)));
    out.put("draftStatus", draft == null ? null : draft.draftStatus);
    out.put("reviewRemark", draft == null ? null : draft.reviewRemark);
    out.put("submittedAt", draft == null ? null : draft.submittedAt);
    out.put("updatedAt", draft == null ? null : draft.updatedAt);
    return out;
  }

  public Map<String, Object> options() {
    var gameRows = new ArrayList<Map<String, Object>>();
    for (var game : playerService.gameOptions()) {
      var row = new LinkedHashMap<>(game);
      long gameId = ((Number) game.get("id")).longValue();
      row.put("positions", playerService.positions(gameId).stream()
          .filter(position -> Boolean.TRUE.equals(position.get("enabled"))).toList());
      gameRows.add(row);
    }
    return Map.of("tags", playerService.tagOptions(), "games", gameRows);
  }

  @Transactional
  public void save(long userId, SelfProfileCommand body) {
    var player = ownPlayer(userId);
    validate(body);
    var existing = draftByPlayer(player.id);
    if (existing != null && "PENDING".equals(existing.draftStatus)) {
      throw new IllegalArgumentException("资料正在审核中，暂时不能修改");
    }
    var command = toPlayerCommand(player, body);
    if (existing == null) {
      existing = new PlayerProfileDraftEntity();
      existing.playerId = player.id;
      existing.profileData = writeCommand(command);
      existing.draftStatus = "DRAFT";
      drafts.insert(existing);
    } else {
      existing.profileData = writeCommand(command);
      existing.draftStatus = "DRAFT";
      existing.reviewRemark = null;
      existing.reviewedBy = null;
      existing.reviewedAt = null;
      existing.updatedAt = LocalDateTime.now();
      drafts.updateById(existing);
    }
  }

  @Transactional
  public void submit(long userId) {
    var draft = draftByPlayer(ownPlayer(userId).id);
    if (draft == null) throw new IllegalArgumentException("请先保存资料草稿");
    if ("PENDING".equals(draft.draftStatus)) throw new IllegalArgumentException("资料已经在审核中");
    draft.draftStatus = "PENDING";
    draft.reviewRemark = null;
    draft.submittedAt = LocalDateTime.now();
    draft.updatedAt = LocalDateTime.now();
    drafts.updateById(draft);
  }

  public List<Map<String, Object>> auditList(String status) {
    var query = new QueryWrapper<PlayerProfileDraftEntity>();
    if (status != null && !status.isBlank()) query.eq("draft_status", status);
    query.orderByDesc("submitted_at", "id");
    return drafts.selectList(query).stream().<Map<String, Object>>map(draft -> {
      var player = players.selectById(draft.playerId);
      var row = new LinkedHashMap<String, Object>();
      row.put("id", draft.id);
      row.put("playerId", draft.playerId);
      row.put("playerNo", player == null ? null : player.playerNo);
      row.put("nickname", player == null ? null : player.nickname);
      row.put("draftStatus", draft.draftStatus);
      row.put("reviewRemark", draft.reviewRemark);
      row.put("submittedAt", draft.submittedAt);
      row.put("reviewedAt", draft.reviewedAt);
      return row;
    }).toList();
  }

  public Map<String, Object> auditDetail(long id) {
    var draft = requireDraft(id);
    return Map.of(
        "id", draft.id,
        "draftStatus", draft.draftStatus,
        "reviewRemark", Objects.toString(draft.reviewRemark, ""),
        "submittedAt", Objects.toString(draft.submittedAt, ""),
        "profile", playerService.player(draft.playerId),
        "draft", selfCommand(readCommand(draft)));
  }

  @Transactional
  public void audit(long id, String action, String remark, long operator) {
    var draft = requireDraft(id);
    if (!"PENDING".equals(draft.draftStatus)) throw new IllegalArgumentException("只有待审核资料可以处理");
    if (!List.of("APPROVE", "REJECT").contains(action)) throw new IllegalArgumentException("审核动作无效");
    if ("REJECT".equals(action) && (remark == null || remark.isBlank())) {
      throw new IllegalArgumentException("驳回时必须填写原因");
    }
    if ("APPROVE".equals(action)) playerService.updatePlayer(draft.playerId, readCommand(draft), operator);
    draft.draftStatus = "APPROVE".equals(action) ? "APPROVED" : "REJECTED";
    draft.reviewRemark = remark;
    draft.reviewedBy = operator;
    draft.reviewedAt = LocalDateTime.now();
    draft.updatedAt = LocalDateTime.now();
    drafts.updateById(draft);

    var audit = new PlayerAuditEntity();
    audit.playerId = draft.playerId;
    audit.auditType = "PROFILE_CHANGE";
    audit.beforeStatus = "PENDING";
    audit.afterStatus = draft.draftStatus;
    audit.result = draft.draftStatus;
    audit.reason = remark;
    audit.auditorId = operator;
    audit.auditedAt = LocalDateTime.now();
    audits.insert(audit);
  }

  private void validate(SelfProfileCommand body) {
    if (body.nickname() == null || body.nickname().isBlank()) throw new IllegalArgumentException("展示昵称不能为空");
    if (body.nickname().length() > 64) throw new IllegalArgumentException("展示昵称不能超过64个字符");
    var tagIds = new LinkedHashSet<>(body.tagIds() == null ? List.<Long>of() : body.tagIds());
    if (tagIds.size() > 8) throw new IllegalArgumentException("最多选择8个标签");
    for (var tagId : tagIds) {
      PlayerTagEntity tag = tags.selectById(tagId);
      if (tag == null || !Boolean.TRUE.equals(tag.enabled)) throw new IllegalArgumentException("所选标签不存在或已停用");
    }
    var gameIds = new LinkedHashSet<Long>();
    int primaryGames = 0;
    for (var item : body.games() == null ? List.<PlayerService.PlayerGameCommand>of() : body.games()) {
      GameEntity game = games.selectById(item.gameId());
      if (game == null || !Boolean.TRUE.equals(game.enabled)) throw new IllegalArgumentException("所选游戏不存在或已停用");
      if (!gameIds.add(item.gameId())) throw new IllegalArgumentException("不能重复添加同一个游戏");
      if (item.primary()) primaryGames++;
      var positionIds = new LinkedHashSet<>(item.positionIds() == null ? List.<Long>of() : item.positionIds());
      if (item.primaryPositionId() != null && !positionIds.contains(item.primaryPositionId())) {
        throw new IllegalArgumentException("主位置必须包含在擅长位置中");
      }
      for (var positionId : positionIds) {
        GamePositionEntity position = positions.selectById(positionId);
        if (position == null || !Boolean.TRUE.equals(position.enabled) || !Objects.equals(position.gameId, item.gameId())) {
          throw new IllegalArgumentException("擅长位置与所选游戏不匹配");
        }
      }
    }
    if (primaryGames > 1) throw new IllegalArgumentException("只能设置一个主游戏");
    if (body.media() != null && body.media().size() > 12) throw new IllegalArgumentException("展示媒体最多上传12项");
  }

  private PlayerService.PlayerCommand toPlayerCommand(PlayerEntity player, SelfProfileCommand body) {
    return new PlayerService.PlayerCommand(
        player.userId, body.nickname(), body.realName(), body.gender(), body.phone(), body.email(),
        body.avatarUrl(), body.coverUrl(), body.introduction(), body.voiceUrl(),
        Boolean.TRUE.equals(player.enabled), Objects.requireNonNullElse(player.sortNo, 0), player.remark,
        body.tagIds(), body.games(), body.media());
  }

  private SelfProfileCommand selfCommand(PlayerService.PlayerCommand command) {
    return new SelfProfileCommand(
        command.nickname(), command.realName(), command.gender(), command.phone(), command.email(),
        command.avatarUrl(), command.coverUrl(), command.introduction(), command.voiceUrl(),
        command.tagIds(), command.games(), command.media());
  }

  private PlayerEntity ownPlayer(long userId) {
    var player = players.selectOne(new QueryWrapper<PlayerEntity>().eq("user_id", userId));
    if (player == null) throw new IllegalArgumentException("当前账号尚未绑定陪玩师资料");
    return player;
  }

  private PlayerProfileDraftEntity draftByPlayer(long playerId) {
    return drafts.selectOne(new QueryWrapper<PlayerProfileDraftEntity>().eq("player_id", playerId));
  }

  private PlayerProfileDraftEntity requireDraft(long id) {
    var draft = drafts.selectById(id);
    if (draft == null) throw new IllegalArgumentException("资料审核记录不存在");
    return draft;
  }

  private String writeCommand(PlayerService.PlayerCommand command) {
    try { return json.writeValueAsString(command); }
    catch (JsonProcessingException e) { throw new IllegalArgumentException("资料保存失败"); }
  }

  private PlayerService.PlayerCommand readCommand(PlayerProfileDraftEntity draft) {
    try { return json.readValue(draft.profileData, PlayerService.PlayerCommand.class); }
    catch (JsonProcessingException e) { throw new IllegalArgumentException("资料草稿无法读取"); }
  }

  public record SelfProfileCommand(
      String nickname,
      String realName,
      String gender,
      String phone,
      String email,
      String avatarUrl,
      String coverUrl,
      String introduction,
      String voiceUrl,
      List<Long> tagIds,
      List<PlayerService.PlayerGameCommand> games,
      List<PlayerService.MediaCommand> media) {}
}
