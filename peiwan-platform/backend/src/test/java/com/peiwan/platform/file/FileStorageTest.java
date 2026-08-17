package com.peiwan.platform.file;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import com.qcloud.cos.COSClient;
import com.qcloud.cos.model.PutObjectRequest;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;

class FileStorageTest {
  @TempDir Path tempDir;

  @Test
  void localStorageKeepsExistingUrlContract() throws Exception {
    var storage = new LocalFileStorage(tempDir.toString());
    var file = new MockMultipartFile("file", "avatar.png", "image/png", "png".getBytes());

    var stored = storage.store(file, "IMAGE");

    assertThat(stored.url()).startsWith("/uploads/").endsWith(".png");
    assertThat(stored.originalName()).isEqualTo("avatar.png");
    assertThat(Files.walk(tempDir).filter(Files::isRegularFile)).hasSize(1);
  }

  @Test
  void cosStorageUploadsAndReturnsPublicUrl() {
    var client = mock(COSClient.class);
    var storage =
        new CosFileStorage(
            client,
            "peiwan-1250000000",
            "ap-guangzhou",
            "https://cdn.example.com/",
            "/peiwan/");
    var file = new MockMultipartFile("file", "avatar.webp", "image/webp", "webp".getBytes());

    var stored = storage.store(file, "IMAGE");

    assertThat(stored.url())
        .startsWith("https://cdn.example.com/peiwan/image/")
        .endsWith(".webp");
    verify(client).putObject(any(PutObjectRequest.class));
  }

  @Test
  void allStorageBackendsShareFileValidation() {
    var storage = new LocalFileStorage(tempDir.toString());
    var file = new MockMultipartFile("file", "script.exe", "application/octet-stream", "x".getBytes());

    assertThatThrownBy(() -> storage.store(file, "IMAGE"))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessage("不支持该文件格式");
  }
}
