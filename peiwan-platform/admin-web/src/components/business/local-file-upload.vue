<template>
  <div class="local-file-upload">
    <div class="flex items-center gap-3">
      <ElImage v-if="modelValue && isImage" :src="modelValue" fit="cover" class="upload-preview" :preview-src-list="[modelValue]" preview-teleported />
      <div v-else-if="modelValue" class="file-preview"><ArtSvgIcon icon="ri:file-line" /></div>
      <ElUpload :show-file-list="false" :accept="accept" :http-request="upload">
        <ElButton :loading="loading" type="primary" plain>{{ modelValue ? '更换文件' : '上传文件' }}</ElButton>
      </ElUpload>
      <ElButton v-if="modelValue" link type="danger" @click="emit('update:modelValue','')">移除</ElButton>
    </div>
    <ElInput class="mt-2" :model-value="modelValue" placeholder="也可以粘贴已有文件地址" clearable @update:model-value="v=>emit('update:modelValue',String(v||''))" />
    <div class="text-xs text-gray-400 mt-1">文件暂存本地，后续切换 OSS 无需修改业务数据</div>
  </div>
</template>
<script setup lang="ts">
  import type { UploadRequestOptions } from 'element-plus'
  import { uploadLocalFile } from '@/api/business-manage'
  const props=withDefaults(defineProps<{modelValue?:string;kind?:'IMAGE'|'MEDIA'|'PROOF';accept?:string}>(),{modelValue:'',kind:'IMAGE',accept:'image/jpeg,image/png,image/gif,image/webp'})
  const emit=defineEmits<{(e:'update:modelValue',value:string):void}>(),loading=ref(false)
  const isImage=computed(()=>/\.(jpe?g|png|gif|webp)(\?.*)?$/i.test(props.modelValue))
  async function upload(options:UploadRequestOptions){loading.value=true;try{const result=await uploadLocalFile(options.file,props.kind);emit('update:modelValue',result.url);ElMessage.success('上传成功');options.onSuccess(result)}catch(error){options.onError(error as any)}finally{loading.value=false}}
</script>
<style scoped>
  .upload-preview,.file-preview{width:72px;height:72px;border:1px solid var(--el-border-color);border-radius:8px}.file-preview{display:flex;align-items:center;justify-content:center;font-size:28px;color:var(--el-text-color-secondary)}
</style>
