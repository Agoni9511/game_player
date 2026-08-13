package com.peiwan.platform;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties={"spring.datasource.url=jdbc:h2:mem:finance;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1","ADMIN_INITIAL_PASSWORD=Test-Only-Password-9x!"})
@AutoConfigureMockMvc
class FinanceCenterTest {
 @Autowired MockMvc mvc;
 @Autowired ObjectMapper json;
 @Autowired JdbcTemplate db;

 @Test void financeMenuAndAdminPermissionAreInstalled(){
  assertThat(db.queryForObject("select p.name from sys_menu m join sys_menu p on p.id=m.parent_id where m.name='FinanceLedger'",String.class)).isEqualTo("FinanceCenter");
  assertThat(db.queryForObject("select count(*) from sys_menu where auth_mark='business:finance:list'",Long.class)).isEqualTo(1);
  assertThat(db.queryForObject("select count(*) from sys_role_menu rm join sys_role r on r.id=rm.role_id join sys_menu m on m.id=rm.menu_id where r.code='admin' and m.name in('FinanceCenter','FinanceLedger')",Long.class)).isEqualTo(2);
 }

 @Test void adminCanQueryEveryFinanceLedgerAndDateValidationWorks() throws Exception {
  String token=login();
  mvc.perform(get("/api/business/finance/summary").header("Authorization",token)).andExpect(status().isOk()).andExpect(jsonPath("$.data.gross_paid_amount").isNumber()).andExpect(jsonPath("$.data.platform_income_amount").isNumber());
  mvc.perform(get("/api/business/finance/payments").header("Authorization",token).param("keyword","RCP")).andExpect(status().isOk()).andExpect(jsonPath("$.data.records").isArray());
  mvc.perform(get("/api/business/finance/platform-ledger").header("Authorization",token)).andExpect(status().isOk()).andExpect(jsonPath("$.data.records").isArray());
  mvc.perform(get("/api/business/finance/wallet-transactions").header("Authorization",token)).andExpect(status().isOk()).andExpect(jsonPath("$.data.records").isArray());
  mvc.perform(get("/api/business/finance/player-transactions").header("Authorization",token)).andExpect(status().isOk()).andExpect(jsonPath("$.data.records").isArray());
  mvc.perform(get("/api/business/finance/settlements").header("Authorization",token)).andExpect(status().isOk()).andExpect(jsonPath("$.data.records").isArray());
  mvc.perform(get("/api/business/finance/summary").header("Authorization",token).param("dateFrom","2026-08-13").param("dateTo","2026-08-12")).andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("开始日期不能晚于结束日期"));
 }

 @Test void anonymousCannotReadFinanceLedgers() throws Exception {
  mvc.perform(get("/api/business/finance/summary")).andExpect(status().isUnauthorized());
 }

 private String login() throws Exception {
  var response=mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(java.util.Map.of("userName","admin","password","Test-Only-Password-9x!")))).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
  return json.readTree(response).at("/data/token").asText();
 }
}
