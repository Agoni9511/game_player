package com.peiwan.platform.file;

import com.qcloud.cos.COSClient;
import com.qcloud.cos.exception.CosClientException;
import com.qcloud.cos.model.ObjectMetadata;
import com.qcloud.cos.model.PutObjectRequest;
import java.io.IOException;
import java.time.LocalDate;
import java.util.Locale;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
@ConditionalOnProperty(name = "app.storage.type", havingValue = "cos")
public class CosFileStorage implements FileStorage {
  private final COSClient cosClient;
  private final String bucket;
  private final String publicBaseUrl;
  private final String prefix;

  public CosFileStorage(
      COSClient cosClient,
      @Value("${app.storage.cos.bucket:}") String bucket,
      @Value("${app.storage.cos.region:}") String region,
      @Value("${app.storage.cos.public-base-url:}") String publicBaseUrl,
      @Value("${app.storage.cos.prefix:peiwan}") String prefix) {
    Assert.hasText(bucket, "COS_BUCKET 不能为空");
    Assert.hasText(region, "COS_REGION 不能为空");
    this.cosClient = cosClient;
    this.bucket = bucket;
    this.publicBaseUrl =
        trimTrailingSlash(
            StringUtils.hasText(publicBaseUrl)
                ? publicBaseUrl
                : "https://" + bucket + ".cos." + region + ".myqcloud.com");
    this.prefix = trimSlashes(prefix);
  }

  @Override
  public StoredFile store(MultipartFile file, String kind) {
    var upload = FileUploadValidator.validate(file, kind);
    var key = createObjectKey(upload);
    var metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    if (StringUtils.hasText(file.getContentType())) metadata.setContentType(file.getContentType());
    try (var input = file.getInputStream()) {
      cosClient.putObject(new PutObjectRequest(bucket, key, input, metadata));
    } catch (IOException | CosClientException e) {
      throw new IllegalStateException("文件上传到 COS 失败", e);
    }
    return new StoredFile(
        publicBaseUrl + "/" + key,
        upload.originalName(),
        file.getSize(),
        file.getContentType());
  }

  private String createObjectKey(FileUploadValidator.ValidatedUpload upload) {
    var now = LocalDate.now();
    var fileName = UUID.randomUUID().toString().replace("-", "") + "." + upload.extension();
    var relative =
        upload.kind().toLowerCase(Locale.ROOT)
            + "/"
            + now.getYear()
            + "/"
            + String.format("%02d", now.getMonthValue())
            + "/"
            + fileName;
    return prefix.isEmpty() ? relative : prefix + "/" + relative;
  }

  private static String trimTrailingSlash(String value) {
    return value.replaceAll("/+$", "");
  }

  private static String trimSlashes(String value) {
    return value == null ? "" : value.replaceAll("^/+|/+$", "");
  }
}
