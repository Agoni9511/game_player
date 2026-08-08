package com.peiwan.platform.file;
import org.springframework.beans.factory.annotation.Value;import org.springframework.stereotype.Service;import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;import java.nio.file.*;import java.time.LocalDate;import java.util.*;
@Service public class LocalFileStorage implements FileStorage{
  private static final Map<String,Set<String>> ALLOWED=Map.of(
    "IMAGE",Set.of("jpg","jpeg","png","gif","webp"),
    "MEDIA",Set.of("jpg","jpeg","png","gif","webp","mp4","webm","mp3","wav","ogg","m4a"),
    "PROOF",Set.of("jpg","jpeg","png","webp","pdf"));
  private final Path root;
  public LocalFileStorage(@Value("${app.storage.local-root:./data/uploads}")String root){this.root=Paths.get(root).toAbsolutePath().normalize();}
  public StoredFile store(MultipartFile file,String kind){if(file==null||file.isEmpty())throw new IllegalArgumentException("请选择要上传的文件");kind=Objects.toString(kind,"IMAGE").toUpperCase();var allowed=ALLOWED.get(kind);if(allowed==null)throw new IllegalArgumentException("文件用途无效");if(file.getSize()>20L*1024*1024)throw new IllegalArgumentException("文件不能超过20MB");String original=Paths.get(Objects.toString(file.getOriginalFilename(),"file")).getFileName().toString();int dot=original.lastIndexOf('.');String ext=dot<0?"":original.substring(dot+1).toLowerCase();if(!allowed.contains(ext))throw new IllegalArgumentException("不支持该文件格式");var now=LocalDate.now();var relative=Paths.get(String.valueOf(now.getYear()),String.format("%02d",now.getMonthValue()),UUID.randomUUID().toString().replace("-","")+"."+ext);var target=root.resolve(relative).normalize();if(!target.startsWith(root))throw new IllegalArgumentException("文件路径无效");try{Files.createDirectories(target.getParent());file.transferTo(target);}catch(IOException e){throw new IllegalStateException("文件保存失败",e);}return new StoredFile("/uploads/"+relative.toString().replace('\\','/'),original,file.getSize(),file.getContentType());}
  public Path root(){return root;}
}
