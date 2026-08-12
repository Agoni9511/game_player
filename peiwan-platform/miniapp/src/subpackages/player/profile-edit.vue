<template>
  <view class="profile-edit page">
    <view class="status-card" :class="statusTone">
      <view><text>资料状态</text><view>{{ statusLabel }}</view></view>
      <text>{{ statusDescription }}</text>
    </view>

    <view class="section-card">
      <view class="section-title">基本资料</view>
      <view class="image-row">
        <view class="image-field" @click="chooseProfileImage('avatarUrl')">
          <image v-if="form.avatarUrl" :src="assetUrl(form.avatarUrl)" mode="aspectFill" />
          <view v-else>头像</view><text>更换头像</text>
        </view>
        <view class="cover-field" @click="chooseProfileImage('coverUrl')">
          <image v-if="form.coverUrl" :src="assetUrl(form.coverUrl)" mode="aspectFill" />
          <view v-else>主页封面</view><text>更换封面</text>
        </view>
      </view>
      <view class="field"><text>展示昵称</text><input v-model.trim="form.nickname" :disabled="readonly" placeholder="请输入展示昵称" /></view>
      <view class="field"><text>真实姓名</text><input v-model.trim="form.realName" :disabled="readonly" placeholder="仅用于平台身份核验" /></view>
      <view class="field"><text>手机号</text><input v-model.trim="form.phone" :disabled="readonly" type="number" placeholder="请输入联系电话" /></view>
      <view class="field"><text>邮箱</text><input v-model.trim="form.email" :disabled="readonly" placeholder="请输入邮箱" /></view>
      <view class="field"><text>绑定账号</text><input v-model="form.loginAccount" disabled placeholder="当前登录账号" /></view>
      <view class="field gender-field"><text>性别</text><view class="choice-row"><view v-for="item in genderOptions" :key="item.value" :class="{ active: form.gender === item.value }" @click="setGender(item.value)">{{ item.label }}</view></view></view>
      <view class="textarea-field"><text>个人介绍</text><textarea v-model="form.introduction" :disabled="readonly" maxlength="500" placeholder="介绍你的游戏经验、服务风格和擅长内容" /></view>
      <view class="upload-line" @click="chooseVoice('voiceUrl')"><view><text>语音介绍</text><label>{{ form.voiceUrl ? '已上传，可重新选择' : '上传语音文件' }}</label></view><text>{{ uploading ? '上传中' : '选择文件' }}</text></view>
    </view>

    <view class="section-card">
      <view class="section-title"><text>个人标签</text><label>最多选择 8 个</label></view>
      <view v-for="group in tagGroups" :key="group.key" class="tag-group">
        <view class="tag-group-title">{{ group.label }}</view>
        <view class="tag-list"><view v-for="tag in group.items" :key="tag.id" class="tag-chip" :class="{ active: form.tagIds.includes(tag.id) }" :style="tagStyle(tag)" @click="toggleTag(tag.id)">{{ tag.tagName }}</view></view>
      </view>
      <view v-if="!tagOptions.length" class="empty-tip">后台暂未配置可用标签</view>
    </view>

    <view class="section-card">
      <view class="section-title"><text>游戏能力</text><label>可添加多个游戏</label></view>
      <picker v-if="availableGames.length && !readonly" mode="selector" :range="availableGames" range-key="gameName" @change="addGame">
        <view class="add-button">＋ 添加擅长游戏</view>
      </picker>
      <view v-for="(game, index) in form.games" :key="game.gameId" class="game-card">
        <view class="game-head"><view><text>{{ gameName(game.gameId) }}</text><label v-if="game.primary">主游戏</label></view><text v-if="!readonly" @click="removeGame(index)">移除</text></view>
        <view class="field"><text>游戏昵称</text><input v-model="game.gameNickname" :disabled="readonly" placeholder="请输入游戏昵称" /></view>
        <view class="field"><text>区服</text><input v-model="game.serverName" :disabled="readonly" placeholder="例如：国服" /></view>
        <view class="field"><text>段位</text><input v-model="game.rankName" :disabled="readonly" placeholder="请输入当前段位" /></view>
        <view class="switch-line"><text>设为主游戏</text><switch :checked="game.primary" :disabled="readonly" color="#315c50" @change="setPrimaryGame(index, $event)" /></view>
        <view class="sub-title">擅长位置</view>
        <view class="tag-list positions"><view v-for="position in positionsFor(game.gameId)" :key="position.id" class="tag-chip" :class="{ active: game.positionIds.includes(position.id) }" @click="togglePosition(game, position.id)">{{ position.positionName }}</view></view>
        <picker v-if="game.positionIds.length && !readonly" mode="selector" :range="selectedPositions(game)" range-key="positionName" @change="setPrimaryPosition(index, $event)">
          <view class="primary-position">主位置：{{ positionName(game.gameId, game.primaryPositionId) || '请选择' }}</view>
        </picker>
        <view class="proof" @click="chooseGameProof(index)"><image v-if="game.proofUrl" :src="assetUrl(game.proofUrl)" mode="aspectFill" /><view v-else>上传游戏证明</view><text>{{ game.proofUrl ? '更换证明' : '支持图片' }}</text></view>
      </view>
      <view v-if="!form.games.length" class="empty-tip">还没有添加游戏资料</view>
    </view>

    <view class="section-card">
      <view class="section-title"><text>展示媒体</text><label>最多 12 项</label></view>
      <view v-if="!readonly" class="media-actions"><button size="mini" @click="addMedia('PHOTO')">添加照片</button><button size="mini" @click="addMedia('VIDEO')">添加视频</button><button size="mini" @click="addMedia('VOICE')">添加语音</button></view>
      <view class="media-grid">
        <view v-for="(media, index) in form.media" :key="media.mediaUrl" class="media-item">
          <image v-if="media.mediaType === 'PHOTO' || media.mediaType === 'GAME_PROOF'" :src="assetUrl(media.mediaUrl)" mode="aspectFill" />
          <view v-else class="file-media">{{ media.mediaType === 'VIDEO' ? '视频' : '语音' }}</view>
          <text v-if="!readonly" @click="form.media.splice(index, 1)">删除</text>
        </view>
      </view>
      <view v-if="!form.media.length" class="empty-tip">还没有上传展示内容</view>
    </view>

    <view class="bottom-space" />
    <view v-if="!readonly" class="bottom-actions"><button class="draft-button" :disabled="saving" @click="saveDraft()">保存草稿</button><button class="submit-button" :disabled="saving" @click="submitForAudit">提交审核</button></view>
  </view>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getOwnPlayerProfile, getOwnPlayerProfileOptions, saveOwnPlayerProfileDraft, submitOwnPlayerProfile } from '@/api/player'
import { assetUrl, uploadFile } from '@/services/http'
import type { RecordData } from '@/types/api'

const form = reactive<any>({ nickname:'', realName:'', gender:'UNKNOWN', phone:'', email:'', loginAccount:'', avatarUrl:'', coverUrl:'', introduction:'', voiceUrl:'', tagIds:[], games:[], media:[] })
const profileData = ref<RecordData>({})
const tagOptions = ref<any[]>([])
const gameOptions = ref<any[]>([])
const saving = ref(false)
const uploading = ref(false)
const genderOptions = [{ label:'未知',value:'UNKNOWN' },{ label:'男',value:'MALE' },{ label:'女',value:'FEMALE' }]
const draftStatus = computed(() => String(profileData.value.draftStatus || ''))
const readonly = computed(() => draftStatus.value === 'PENDING')
const statusLabel = computed(() => ({ DRAFT:'草稿待提交',PENDING:'平台审核中',APPROVED:'审核已通过',REJECTED:'审核未通过' } as Record<string,string>)[draftStatus.value] || '当前正式资料')
const statusDescription = computed(() => draftStatus.value === 'REJECTED' ? String(profileData.value.reviewRemark || '请修改后重新提交') : readonly.value ? '审核期间暂时不能修改资料' : '修改内容提交审核后才会更新展示')
const statusTone = computed(() => draftStatus.value.toLowerCase())
const availableGames = computed(() => gameOptions.value.filter(game => !form.games.some((item:any) => item.gameId === game.id)))
const tagGroups = computed(() => {
  const labels:Record<string,string> = { SKILL:'技术特点', STYLE:'服务风格', VOICE:'声音特点', TIME:'在线时段', OTHER:'其他标签' }
  const rows = new Map<string,any[]>()
  tagOptions.value.forEach(tag => { const key=String(tag.tagGroup||'OTHER'); rows.set(key,[...(rows.get(key)||[]),tag]) })
  return [...rows.entries()].map(([key,items]) => ({ key,label:labels[key]||'其他标签',items }))
})

onLoad(load)

async function load() {
  const [data, options] = await Promise.all([getOwnPlayerProfile(), getOwnPlayerProfileOptions()])
  profileData.value = data
  tagOptions.value = (options.tags || []) as any[]
  gameOptions.value = (options.games || []) as any[]
  applySource((data.draft || data.profile || {}) as RecordData)
}
function applySource(source:RecordData) {
  Object.assign(form, {
    nickname:String(source.nickname || ''), realName:String(source.realName || ''), gender:String(source.gender || 'UNKNOWN'), phone:String(source.phone || ''), email:String(source.email || ''), loginAccount:String(source.loginAccount || (profileData.value.profile as RecordData | undefined)?.loginAccount || ''),
    avatarUrl:String(source.avatarUrl || ''), coverUrl:String(source.coverUrl || ''), introduction:String(source.introduction || ''), voiceUrl:String(source.voiceUrl || ''),
    tagIds:[...((source.tagIds || []) as number[])],
    games:((source.games || []) as any[]).map(game => ({ gameId:Number(game.gameId),gameNickname:String(game.gameNickname||''),gameAccount:String(game.gameAccount||''),serverName:String(game.serverName||''),rankName:String(game.rankName||''),rankLevel:game.rankLevel||null,experienceYears:game.experienceYears||null,introduction:String(game.introduction||''),proofUrl:String(game.proofUrl||''),primary:Boolean(game.primary),enabled:game.enabled!==false,positionIds:[...(game.positionIds||[])],primaryPositionId:game.primaryPositionId||null })),
    media:((source.media || []) as any[]).map((media,index) => ({ mediaType:String(media.mediaType||'PHOTO'),mediaUrl:String(media.mediaUrl||''),thumbnailUrl:String(media.thumbnailUrl||''),title:String(media.title||''),sortNo:Number(media.sortNo??index),enabled:media.enabled!==false }))
  })
}
function setGender(value:string) { if (!readonly.value) form.gender = value }
function toggleTag(id:number) { if (readonly.value) return; const index=form.tagIds.indexOf(id); if(index>=0)form.tagIds.splice(index,1); else if(form.tagIds.length<8)form.tagIds.push(id); else uni.showToast({title:'最多选择8个标签',icon:'none'}) }
function tagStyle(tag:any) { const color=String(tag.tagColor||'#315c50'); return form.tagIds.includes(tag.id) ? {backgroundColor:color,borderColor:color,color:'#fff'} : {borderColor:color,color} }
function gameName(id:number) { return gameOptions.value.find(game => game.id===id)?.gameName || '游戏资料' }
function positionsFor(gameId:number) { return gameOptions.value.find(game => game.id===gameId)?.positions || [] }
function selectedPositions(game:any) { return positionsFor(game.gameId).filter((position:any) => game.positionIds.includes(position.id)) }
function positionName(gameId:number,id:number|null) { return positionsFor(gameId).find((position:any) => position.id===id)?.positionName || '' }
function addGame(event:any) { const game=availableGames.value[Number(event.detail.value)]; if(!game)return; form.games.push({gameId:game.id,gameNickname:'',gameAccount:'',serverName:'',rankName:'',rankLevel:null,experienceYears:null,introduction:'',proofUrl:'',primary:form.games.length===0,enabled:true,positionIds:[],primaryPositionId:null}) }
function removeGame(index:number) { if(!readonly.value)form.games.splice(index,1) }
function setPrimaryGame(index:number,event:any) { if(readonly.value)return; const checked=Boolean(event.detail.value); form.games.forEach((game:any,i:number)=>game.primary=checked&&i===index) }
function togglePosition(game:any,id:number) { if(readonly.value)return; const index=game.positionIds.indexOf(id); if(index>=0){game.positionIds.splice(index,1);if(game.primaryPositionId===id)game.primaryPositionId=null}else game.positionIds.push(id) }
function setPrimaryPosition(index:number,event:any) { const game=form.games[index], rows=selectedPositions(game); game.primaryPositionId=rows[Number(event.detail.value)]?.id||null }

async function chooseProfileImage(field:'avatarUrl'|'coverUrl') { if(readonly.value)return; const result=await uni.chooseImage({count:1}); await upload(result.tempFilePaths[0],url=>form[field]=url,'IMAGE') }
async function chooseGameProof(index:number) { if(readonly.value)return; const result=await uni.chooseImage({count:1}); await upload(result.tempFilePaths[0],url=>form.games[index].proofUrl=url,'PROOF') }
async function chooseVoice(field:'voiceUrl') { if(readonly.value)return; const path=await chooseMessageFile(['mp3','wav','m4a']); if(path)await upload(path,url=>form[field]=url,'MEDIA') }
async function addMedia(type:'PHOTO'|'VIDEO'|'VOICE') {
  if(readonly.value||form.media.length>=12)return uni.showToast({title:'展示媒体最多12项',icon:'none'})
  let path=''
  if(type==='PHOTO')path=(await uni.chooseImage({count:1})).tempFilePaths[0]
  if(type==='VIDEO')path=(await uni.chooseVideo({sourceType:['album','camera']})).tempFilePath
  if(type==='VOICE')path=await chooseMessageFile(['mp3','wav','m4a'])
  if(path)await upload(path,url=>form.media.push({mediaType:type,mediaUrl:url,thumbnailUrl:'',title:'',sortNo:form.media.length,enabled:true}),'MEDIA')
}
function chooseMessageFile(extension:string[]):Promise<string> { return new Promise(resolve => { const wechat=(globalThis as any).wx; wechat.chooseMessageFile({count:1,type:'file',extension,success:(result:any)=>resolve(result.tempFiles?.[0]?.path||''),fail:()=>resolve('')}) }) }
async function upload(path:string,done:(url:string)=>void,kind:string) { uploading.value=true;uni.showLoading({title:'上传中'});try{done(await uploadFile(path,kind))}finally{uploading.value=false;uni.hideLoading()} }
function payload():RecordData { const data=JSON.parse(JSON.stringify(form));delete data.loginAccount;return data }
async function saveDraft(showMessage=true) { if(!form.nickname.trim())return uni.showToast({title:'请填写展示昵称',icon:'none'});saving.value=true;try{await saveOwnPlayerProfileDraft(payload());if(showMessage)uni.showToast({title:'草稿已保存',icon:'success'});await load()}finally{saving.value=false} }
function submitForAudit() { uni.showModal({title:'提交资料审核',content:'提交后审核完成前不能继续修改，确认提交吗？',confirmText:'确认提交',success:async result=>{if(!result.confirm)return;await saveDraft(false);saving.value=true;try{await submitOwnPlayerProfile();uni.showToast({title:'已提交审核',icon:'success'});await load()}finally{saving.value=false}}}) }
</script>

<style scoped lang="scss">
.profile-edit{padding:24rpx 24rpx 150rpx;background:#eee9da}.status-card{margin-bottom:22rpx;padding:24rpx 26rpx;border-radius:24rpx;display:flex;align-items:center;justify-content:space-between;color:#315c50;background:#dfe9df}.status-card>view text{font-size:20rpx}.status-card>view view{margin-top:7rpx;font-size:29rpx;font-weight:800}.status-card>text{max-width:360rpx;color:#75837b;font-size:20rpx;text-align:right}.status-card.pending{color:#8b6236;background:#f2e6ce}.status-card.rejected{color:#963d31;background:#f0ddd5}.section-card{margin-bottom:22rpx;padding:28rpx 26rpx;border:1rpx solid rgba(54,79,68,.16);border-radius:28rpx;background:rgba(255,252,241,.95);box-shadow:0 10rpx 28rpx rgba(38,54,45,.06)}.section-title{margin-bottom:24rpx;display:flex;align-items:center;justify-content:space-between;font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.section-title label{color:#839088;font-family:sans-serif;font-size:19rpx;font-weight:400}.image-row{margin-bottom:20rpx;display:flex;gap:18rpx}.image-field,.cover-field{position:relative;height:130rpx;overflow:hidden;border-radius:22rpx;display:flex;align-items:center;justify-content:center;color:#708078;background:#e4e8dc}.image-field{width:130rpx;flex:none}.cover-field{flex:1}.image-field image,.cover-field image{width:100%;height:100%}.image-field>text,.cover-field>text{position:absolute;left:0;right:0;bottom:0;padding:8rpx;color:#fff;text-align:center;background:rgba(24,46,38,.64);font-size:18rpx}.field{min-height:88rpx;border-bottom:1rpx solid rgba(49,92,80,.12);display:flex;align-items:center}.field>text{width:150rpx;flex:none;color:#506159;font-size:23rpx}.field input{flex:1;text-align:right;font-size:24rpx}.textarea-field{padding-top:22rpx}.textarea-field>text{color:#506159;font-size:23rpx}.textarea-field textarea{width:100%;height:150rpx;margin-top:14rpx;padding:18rpx;box-sizing:border-box;border-radius:20rpx;background:#ececdf;font-size:23rpx}.choice-row{flex:1;display:flex;justify-content:flex-end;gap:10rpx}.choice-row view,.tag-chip{padding:10rpx 17rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:22rpx;color:#748078;background:#f5f2e8;font-size:21rpx}.choice-row .active,.tag-chip.active{border-color:#315c50;color:#fffaf0;background:#315c50}.upload-line,.switch-line{min-height:88rpx;display:flex;align-items:center;justify-content:space-between}.upload-line>view text,.upload-line>view label{display:block}.upload-line>view text,.switch-line>text{color:#506159;font-size:23rpx}.upload-line>view label{margin-top:6rpx;color:#919a94;font-size:18rpx}.upload-line>text{color:#315c50;font-size:21rpx}.tag-list{display:flex;flex-wrap:wrap;gap:12rpx}.add-button{height:76rpx;margin-bottom:20rpx;border:2rpx dashed #9aada1;border-radius:22rpx;color:#315c50;line-height:76rpx;text-align:center}.game-card{margin-top:18rpx;padding:22rpx;border:1rpx solid rgba(49,92,80,.16);border-radius:24rpx;background:#f8f5e9}.game-head{display:flex;align-items:center;justify-content:space-between}.game-head>view text{font-size:27rpx;font-weight:800}.game-head label{margin-left:10rpx;padding:4rpx 10rpx;border-radius:12rpx;color:#fff;background:#963d31;font-size:17rpx}.game-head>text{color:#963d31;font-size:20rpx}.sub-title{margin:20rpx 0 14rpx;color:#506159;font-size:22rpx}.positions .tag-chip{padding:8rpx 14rpx}.primary-position{margin-top:18rpx;padding:16rpx;border-radius:18rpx;color:#315c50;background:#e2e9df;font-size:21rpx}.proof{height:150rpx;margin-top:18rpx;overflow:hidden;border:2rpx dashed #a8b5aa;border-radius:20rpx;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#718078}.proof image{width:100%;height:100%}.proof text{margin-top:6rpx;font-size:18rpx}.media-actions{display:flex;gap:12rpx}.media-actions button{margin:0;color:#315c50;background:#e4e9df}.media-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14rpx;margin-top:20rpx}.media-item{position:relative;height:150rpx;overflow:hidden;border-radius:20rpx;background:#e4e8dc}.media-item image,.file-media{width:100%;height:100%}.file-media{display:flex;align-items:center;justify-content:center;color:#315c50;font-size:28rpx;font-weight:800}.media-item>text{position:absolute;right:7rpx;top:7rpx;padding:5rpx 10rpx;border-radius:15rpx;color:#fff;background:rgba(150,61,49,.82);font-size:17rpx}.empty-tip{padding:30rpx 0;color:#929b95;text-align:center;font-size:21rpx}.bottom-actions{position:fixed;z-index:20;left:0;right:0;bottom:0;padding:14rpx 24rpx calc(14rpx + env(safe-area-inset-bottom));display:flex;gap:16rpx;background:rgba(255,252,241,.97);box-shadow:0 -8rpx 28rpx rgba(40,55,46,.12)}.bottom-actions button{height:82rpx;margin:0;border-radius:42rpx;line-height:82rpx;font-size:26rpx}.draft-button{width:220rpx;color:#315c50;background:#e2e9df}.submit-button{flex:1;color:#fffaf0;background:#315c50}
.tag-group+.tag-group{margin-top:22rpx}.tag-group-title{margin-bottom:12rpx;color:#7b877f;font-size:20rpx}
</style>
