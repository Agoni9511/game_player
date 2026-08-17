package com.peiwan.platform.file;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@ConditionalOnProperty(name = "app.storage.type", havingValue = "local", matchIfMissing = true)
public class LocalFileStorage implements FileStorage {
  private final Path root;

  public LocalFileStorage(@Value("${app.storage.local.root:./data/uploads}") String root) {
    this.root = Paths.get(root).toAbsolutePath().normalize();
  }

  @Override
  public StoredFile store(MultipartFile file, String kind) {
    var upload = FileUploadValidator.validate(file, kind);
    var now = LocalDate.now();
    var relative =
        Paths.get(
            String.valueOf(now.getYear()),
            String.format("%02d", now.getMonthValue()),
            UUID.randomUUID().toString().replace("-", "") + "." + upload.extension());
    var target = root.resolve(relative).normalize();
    if (!target.startsWith(root)) throw new IllegalArgumentException("文件路径无效");
    try {
      Files.createDirectories(target.getParent());
      file.transferTo(target);
    } catch (IOException e) {
      throw new IllegalStateException("文件保存失败", e);
    }
    return new StoredFile(
        "/uploads/" + relative.toString().replace('\\', '/'),
        upload.originalName(),
        file.getSize(),
        file.getContentType());
  }

  public Path root() {
    return root;
  }
}
