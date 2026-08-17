package com.peiwan.platform.file;

import com.qcloud.cos.COSClient;
import com.qcloud.cos.ClientConfig;
import com.qcloud.cos.auth.BasicCOSCredentials;
import com.qcloud.cos.http.HttpProtocol;
import com.qcloud.cos.region.Region;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.Assert;

@Configuration
@ConditionalOnProperty(name = "app.storage.type", havingValue = "cos")
public class CosStorageConfig {
  @Bean(destroyMethod = "shutdown")
  COSClient cosClient(
      @Value("${app.storage.cos.secret-id:}") String secretId,
      @Value("${app.storage.cos.secret-key:}") String secretKey,
      @Value("${app.storage.cos.region:}") String region) {
    Assert.hasText(secretId, "COS_SECRET_ID 不能为空");
    Assert.hasText(secretKey, "COS_SECRET_KEY 不能为空");
    Assert.hasText(region, "COS_REGION 不能为空");
    var credentials = new BasicCOSCredentials(secretId, secretKey);
    var clientConfig = new ClientConfig(new Region(region));
    clientConfig.setHttpProtocol(HttpProtocol.https);
    return new COSClient(credentials, clientConfig);
  }
}
