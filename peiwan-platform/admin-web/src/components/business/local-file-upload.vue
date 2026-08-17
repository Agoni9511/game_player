<template>
  <div class="asset-upload" :class="[`is-${assetType}`, { 'is-wide': assetType !== 'image' }]">
    <div v-if="modelValue" class="asset-preview">
      <ElImage
        v-if="assetType === 'image'"
        :src="modelValue"
        fit="cover"
        class="asset-image"
        :preview-src-list="[modelValue]"
        preview-teleported
      />
      <video v-else-if="assetType === 'video'" :src="modelValue" class="asset-video" controls />
      <div v-else-if="assetType === 'audio'" class="audio-preview">
        <ArtSvgIcon icon="ri:volume-up-line" class="asset-icon" />
        <audio :src="modelValue" controls />
      </div>
      <a
        v-else
        :href="modelValue"
        target="_blank"
        rel="noopener noreferrer"
        class="document-preview"
      >
        <ArtSvgIcon
          :icon="assetType === 'pdf' ? 'ri:file-pdf-2-line' : 'ri:file-line'"
          class="asset-icon"
        />
        <span>{{ fileName }}</span>
        <small>点击查看文件</small>
      </a>

      <div class="asset-actions">
        <ElUpload
          :show-file-list="false"
          :accept="accept"
          :http-request="upload"
          :disabled="loading"
        >
          <ElButton text type="primary" :loading="loading">
            <ElIcon><Refresh /></ElIcon>
            更换
          </ElButton>
        </ElUpload>
        <ElButton text type="danger" :disabled="loading" @click="remove">
          <ElIcon><Delete /></ElIcon>
          删除
        </ElButton>
      </div>
    </div>

    <ElUpload
      v-else
      class="asset-picker"
      :class="{ 'picture-picker': assetType === 'image' }"
      :show-file-list="false"
      :accept="accept"
      :http-request="upload"
      :disabled="loading"
    >
      <div class="picker-content">
        <ElIcon class="picker-icon"><Loading v-if="loading" /><Plus v-else /></ElIcon>
        <strong>{{ loading ? '正在上传' : pickerTitle }}</strong>
        <span>{{ pickerHint }}</span>
      </div>
    </ElUpload>
  </div>
</template>

<script setup lang="ts">
  import { Delete, Loading, Plus, Refresh } from '@element-plus/icons-vue'
  import type { UploadRequestOptions } from 'element-plus'
  import { uploadLocalFile } from '@/api/business-manage'

  const props = withDefaults(
    defineProps<{
      modelValue?: string
      kind?: 'IMAGE' | 'MEDIA' | 'PROOF'
      accept?: string
      display?: 'form' | 'picture-card'
    }>(),
    {
      modelValue: '',
      kind: 'IMAGE',
      accept: 'image/jpeg,image/png,image/gif,image/webp',
      display: 'form'
    }
  )
  const emit = defineEmits<{ (e: 'update:modelValue', value: string): void }>()
  const loading = ref(false)

  type AssetType = 'image' | 'video' | 'audio' | 'pdf' | 'file'

  const assetType = computed<AssetType>(() => {
    const source = String(props.modelValue || '')
      .split('?')[0]
      .toLowerCase()
    if (/\.(jpe?g|png|gif|webp|bmp|svg)$/.test(source)) return 'image'
    if (/\.(mp4|webm|mov|m4v)$/.test(source)) return 'video'
    if (/\.(mp3|wav|ogg|m4a|aac)$/.test(source)) return 'audio'
    if (/\.pdf$/.test(source)) return 'pdf'

    const accept = props.accept.toLowerCase()
    if (accept.includes('video/') && !accept.includes('image/') && !accept.includes('audio/'))
      return 'video'
    if (accept.includes('audio/') && !accept.includes('image/') && !accept.includes('video/'))
      return 'audio'
    if (accept.includes('application/pdf') && !accept.includes('image/')) return 'pdf'
    if (accept.includes('image/') && !accept.includes('video/') && !accept.includes('audio/'))
      return 'image'
    return 'file'
  })

  const fileName = computed(() => {
    const path = String(props.modelValue || '').split('?')[0]
    return decodeURIComponent(path.split('/').pop() || '已上传文件')
  })
  const pickerTitle = computed(
    () =>
      ({
        image: '上传图片',
        video: '上传视频',
        audio: '上传音频',
        pdf: '上传 PDF',
        file: '上传文件'
      })[assetType.value]
  )
  const pickerHint = computed(
    () =>
      ({
        image: 'JPG、PNG、GIF 或 WebP',
        video: 'MP4 或 WebM',
        audio: 'MP3、WAV 或 OGG',
        pdf: 'PDF 文件',
        file: '选择符合要求的文件'
      })[assetType.value]
  )

  function remove() {
    emit('update:modelValue', '')
  }

  async function upload(options: UploadRequestOptions) {
    loading.value = true
    try {
      const result = await uploadLocalFile(options.file, props.kind)
      emit('update:modelValue', result.url)
      ElMessage.success('上传成功')
      options.onSuccess(result)
    } catch (error) {
      options.onError(error as any)
    } finally {
      loading.value = false
    }
  }
</script>

<style scoped>
  .asset-upload {
    width: 144px;
    max-width: 100%;
  }

  .asset-upload.is-wide {
    width: min(100%, 520px);
  }

  .asset-picker {
    display: block;
    width: 100%;
  }

  .asset-picker :deep(.el-upload) {
    display: block;
    width: 100%;
  }

  .picker-content {
    display: flex;
    flex-direction: column;
    gap: 7px;
    align-items: center;
    justify-content: center;
    min-height: 112px;
    padding: 18px;
    color: var(--el-text-color-secondary);
    cursor: pointer;
    background: var(--el-fill-color-lighter);
    border: 1px dashed var(--el-border-color);
    border-radius: 10px;
    transition: all 0.2s ease;
  }

  .picture-picker .picker-content {
    width: 144px;
    height: 144px;
    min-height: 144px;
    padding: 10px;
  }

  .picker-content:hover {
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-9);
    border-color: var(--el-color-primary);
  }

  .picker-icon {
    font-size: 28px;
  }

  .picker-content strong {
    font-size: 14px;
    font-weight: 500;
  }

  .picker-content span {
    font-size: 12px;
    color: var(--el-text-color-placeholder);
  }

  .asset-preview {
    position: relative;
    width: 100%;
    min-height: 144px;
    overflow: hidden;
    background: var(--el-fill-color-lighter);
    border: 1px solid var(--el-border-color-light);
    border-radius: 10px;
  }

  .asset-image,
  .asset-video {
    display: block;
    width: 100%;
    height: 144px;
    background: #000;
  }

  .asset-actions {
    display: flex;
    gap: 8px;
    align-items: center;
    justify-content: center;
    min-height: 42px;
    background: var(--el-bg-color);
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .audio-preview,
  .document-preview {
    display: flex;
    flex-direction: column;
    gap: 8px;
    align-items: center;
    justify-content: center;
    min-height: 112px;
    padding: 16px;
    color: var(--el-text-color-regular);
    text-decoration: none;
  }

  .audio-preview audio {
    width: min(100%, 420px);
    height: 40px;
  }

  .asset-icon {
    font-size: 34px;
    color: var(--el-color-primary);
  }

  .document-preview span {
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .document-preview small {
    color: var(--el-text-color-placeholder);
  }
</style>
