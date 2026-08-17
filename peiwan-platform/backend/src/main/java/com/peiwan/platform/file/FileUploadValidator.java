package com.peiwan.platform.file;

import java.nio.file.InvalidPathException;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import org.springframework.web.multipart.MultipartFile;

final class FileUploadValidator {
  private static final long MAX_FILE_SIZE = 20L * 1024 * 1024;
  private static final Map<String, Set<String>> ALLOWED =
      Map.of(
          "IMAGE", Set.of("jpg", "jpeg", "png", "gif", "webp"),
          "MEDIA", Set.of("jpg", "jpeg", "png", "gif", "webp", "mp4", "webm", "mp3", "wav", "ogg", "m4a"),
          "PROOF", Set.of("jpg", "jpeg", "png", "webp", "pdf"));

  private FileUploadValidator() {}

  static ValidatedUpload validate(MultipartFile file, String kind) {
    if (file == null || file.isEmpty()) throw new IllegalArgumentException("请选择要上传的文件");
    if (file.getSize() > MAX_FILE_SIZE) throw new IllegalArgumentException("文件不能超过20MB");

    var normalizedKind = Objects.toString(kind, "IMAGE").toUpperCase(Locale.ROOT);
    var allowedExtensions = ALLOWED.get(normalizedKind);
    if (allowedExtensions == null) throw new IllegalArgumentException("文件用途无效");

    String originalName;
    try {
      originalName =
          Paths.get(Objects.toString(file.getOriginalFilename(), "file")).getFileName().toString();
    } catch (InvalidPathException e) {
      throw new IllegalArgumentException("文件名无效", e);
    }
    var dot = originalName.lastIndexOf('.');
    var extension = dot < 0 ? "" : originalName.substring(dot + 1).toLowerCase(Locale.ROOT);
    if (!allowedExtensions.contains(extension)) throw new IllegalArgumentException("不支持该文件格式");
    return new ValidatedUpload(normalizedKind, originalName, extension);
  }

  record ValidatedUpload(String kind, String originalName, String extension) {}
}
