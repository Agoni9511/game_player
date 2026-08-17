package com.peiwan.platform.system;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.peiwan.platform.persistence.entity.PlayerEntity;
import com.peiwan.platform.persistence.entity.SystemRoleEntity;
import com.peiwan.platform.persistence.entity.SystemUserEntity;
import com.peiwan.platform.persistence.mapper.PlayerMapper;
import com.peiwan.platform.persistence.mapper.SystemRelationMapper;
import com.peiwan.platform.persistence.mapper.SystemRoleMapper;
import com.peiwan.platform.persistence.mapper.SystemUserMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Component
public class BootstrapData implements CommandLineRunner {
  private final SystemUserMapper users;
  private final SystemRoleMapper roles;
  private final SystemRelationMapper relations;
  private final PlayerMapper players;
  private final PasswordEncoder encoder;
  private final String adminPassword;

  public BootstrapData(
      SystemUserMapper users,
      SystemRoleMapper roles,
      SystemRelationMapper relations,
      PlayerMapper players,
      PasswordEncoder encoder,
      @Value("${app.admin.initial-password:${ADMIN_INITIAL_PASSWORD:123456}}") String adminPassword) {
    this.users = users;
    this.roles = roles;
    this.relations = relations;
    this.players = players;
    this.encoder = encoder;
    this.adminPassword = adminPassword;
  }

  @Override
  public void run(String... args) {
    var admin = users.selectOne(new QueryWrapper<SystemUserEntity>().eq("username", "admin"));
    if (admin == null) {
      admin = new SystemUserEntity();
      admin.username = "admin";
      admin.password = encoder.encode(adminPassword);
      admin.nickname = "超级管理员";
      admin.email = "admin@peiwan.local";
      admin.gender = "未知";
      admin.enabled = true;
      users.insert(admin);
    } else if (!encoder.matches(adminPassword, admin.password)) {
      admin.password = encoder.encode(adminPassword);
      users.updateById(admin);
    }

    var role = roles.selectOne(new QueryWrapper<SystemRoleEntity>().eq("code", "admin"));
    if (role == null) {
      throw new IllegalStateException("MySQL 未初始化 admin 角色");
    }
    if (relations.hasUserRole(admin.id, role.id) == 0) {
      relations.addUserRole(admin.id, role.id);
    }
    relations.grantAllMenus(role.id);

    var customerRole = roles.selectOne(new QueryWrapper<SystemRoleEntity>().eq("code", "customer"));
    if (customerRole == null) {
      throw new IllegalStateException("MySQL 未初始化 customer 角色");
    }
    var customer = ensureAccount("customer", "用户端测试账号");
    grantRole(customer, customerRole);

    var playerRole = roles.selectOne(new QueryWrapper<SystemRoleEntity>().eq("code", "player"));
    if (playerRole == null) {
      throw new IllegalStateException("MySQL 未初始化 player 角色");
    }
    var playerUser = ensureAccount("player", "陪玩师测试账号");
    grantRole(playerUser, customerRole);
    grantRole(playerUser, playerRole);

    var player = players.selectOne(new QueryWrapper<PlayerEntity>().eq("user_id", playerUser.id));
    if (player == null) {
      player = new PlayerEntity();
      player.playerNo = "TEST-PLAYER-001";
      player.userId = playerUser.id;
      player.nickname = "测试陪玩师";
      player.realName = "测试账号";
      player.gender = "UNKNOWN";
      player.introduction = "用于小程序陪玩师端功能测试";
      player.auditStatus = "APPROVED";
      player.workStatus = "OFFLINE";
      player.enabled = true;
      player.auditRemark = "系统测试账号自动审核通过";
      player.approvedAt = LocalDateTime.now();
      player.maxActiveOrders = 3;
      player.ratingScore = new BigDecimal("5.00");
      player.ratingCount = 0;
      player.orderCount = 0;
      player.sortNo = 99;
      player.createdBy = admin.id;
      player.updatedBy = admin.id;
      players.insert(player);
    } else if (!Boolean.TRUE.equals(player.enabled) || !"APPROVED".equals(player.auditStatus)) {
      player.enabled = true;
      player.auditStatus = "APPROVED";
      player.auditRemark = "系统测试账号自动审核通过";
      player.approvedAt = LocalDateTime.now();
      players.updateById(player);
    }
  }

  private SystemUserEntity ensureAccount(String username, String nickname) {
    var user = users.selectOne(new QueryWrapper<SystemUserEntity>().eq("username", username));
    if (user == null) {
      user = new SystemUserEntity();
      user.username = username;
      user.password = encoder.encode("123456");
      user.nickname = nickname;
      user.email = username + "@peiwan.local";
      user.gender = "未知";
      user.enabled = true;
      users.insert(user);
    } else if (!encoder.matches("123456", user.password) || !Boolean.TRUE.equals(user.enabled)) {
      user.password = encoder.encode("123456");
      user.enabled = true;
      users.updateById(user);
    }
    return user;
  }

  private void grantRole(SystemUserEntity user, SystemRoleEntity role) {
    if (relations.hasUserRole(user.id, role.id) == 0) {
      relations.addUserRole(user.id, role.id);
    }
  }
}
