package com.peiwan.platform.file;
import org.springframework.web.multipart.MultipartFile;
public interface FileStorage { StoredFile store(MultipartFile file,String kind); record StoredFile(String url,String originalName,long size,String contentType){} }
