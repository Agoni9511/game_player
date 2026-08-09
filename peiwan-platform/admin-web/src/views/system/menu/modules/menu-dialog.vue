<template>
  <ElDialog v-model="visible" :title="editData?.id?'编辑权限资源':'新增权限资源'" width="620px" @open="init">
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="100px">
      <ElFormItem label="类型" prop="type"><ElRadioGroup v-model="form.type" :disabled="!!editData?.id"><ElRadioButton value="DIRECTORY">目录</ElRadioButton><ElRadioButton value="MENU">菜单</ElRadioButton><ElRadioButton value="BUTTON">按钮</ElRadioButton></ElRadioGroup></ElFormItem>
      <ElFormItem label="父节点"><ElTreeSelect v-model="form.parentId" :data="options" node-key="id" check-strictly clearable :props="{label:'label',children:'children'}" class="w-full" /></ElFormItem>
      <ElFormItem label="显示名称" prop="title"><ElInput v-model="form.title" /></ElFormItem>
      <ElFormItem label="唯一名称" prop="name"><ElInput v-model="form.name" placeholder="如 User 或 UserCreate" /></ElFormItem>
      <template v-if="form.type!=='BUTTON'">
        <ElFormItem label="路由路径" prop="path"><ElInput v-model="form.path" placeholder="一级 /system，子级 user" /></ElFormItem>
        <ElFormItem label="组件路径"><ElInput v-model="form.component" placeholder="目录 /index/index，页面 /system/user" /></ElFormItem>
        <ElFormItem label="图标">
          <div class="flex items-center gap-2 w-full">
            <div class="size-10 shrink-0 rounded border border-g-300 flex-cc text-xl text-theme">
              <ArtSvgIcon v-if="form.icon" :icon="form.icon" />
              <span v-else class="text-xs text-g-500">无</span>
            </div>
            <ElSelect
              v-model="form.icon"
              filterable
              allow-create
              clearable
              default-first-option
              placeholder="搜索或输入 Iconify 图标编码"
              class="flex-1"
            >
              <ElOption v-for="item in iconOptions" :key="item.value" :label="`${item.label} ${item.value}`" :value="item.value">
                <div class="flex items-center gap-3"><ArtSvgIcon :icon="item.value" class="text-lg" /><span class="w-20">{{ item.label }}</span><span class="text-xs text-g-500">{{ item.value }}</span></div>
              </ElOption>
            </ElSelect>
          </div>
        </ElFormItem>
        <ElFormItem label="隐藏"><ElSwitch v-model="form.hidden" /></ElFormItem>
        <ElFormItem label="页面缓存"><ElSwitch v-model="form.keepAlive" /></ElFormItem>
      </template>
      <ElFormItem v-else label="权限编码" prop="authMark"><ElInput v-model="form.authMark" placeholder="system:user:create" /></ElFormItem>
      <ElFormItem label="排序"><ElInputNumber v-model="form.sortNo" :min="0" /></ElFormItem>
      <ElFormItem label="启用"><ElSwitch v-model="form.enabled" /></ElFormItem>
    </ElForm>
    <template #footer><ElButton @click="visible=false">取消</ElButton><ElButton type="primary" @click="submit">保存</ElButton></template>
  </ElDialog>
</template>

<script setup lang="ts">
  import type { FormInstance,FormRules } from 'element-plus'
  const props=defineProps<{visible:boolean;editData?:any;parentId?:number|null;options:any[]}>();const emit=defineEmits<{(e:'update:visible',v:boolean):void;(e:'submit',data:Api.SystemManage.MenuSaveParams & {id?:number}):void}>()
  const visible=computed({get:()=>props.visible,set:v=>emit('update:visible',v)});const formRef=ref<FormInstance>()
  const empty=():Api.SystemManage.MenuSaveParams=>({parentId:props.parentId??null,type:props.editData?.initialType||'MENU',name:'',path:'',component:'',title:'',icon:'',authMark:'',sortNo:0,hidden:false,enabled:true,keepAlive:false})
  const form=reactive<Api.SystemManage.MenuSaveParams>(empty())
  const iconOptions=[
    ['首页','ri:home-4-line'],['控制台','ri:dashboard-line'],['系统设置','ri:settings-3-line'],['用户','ri:user-3-line'],
    ['用户组','ri:group-line'],['角色权限','ri:shield-user-line'],['菜单','ri:menu-2-line'],['列表','ri:file-list-3-line'],
    ['登录','ri:login-box-line'],['日志','ri:file-history-line'],['搜索','ri:search-line'],['通知','ri:notification-3-line'],
    ['消息','ri:message-3-line'],['订单','ri:file-list-2-line'],['商品','ri:shopping-bag-3-line'],['购物车','ri:shopping-cart-2-line'],
    ['钱包','ri:wallet-3-line'],['支付','ri:bank-card-line'],['金额','ri:money-cny-circle-line'],['统计','ri:bar-chart-2-line'],
    ['趋势','ri:line-chart-line'],['数据','ri:database-2-line'],['文件夹','ri:folder-3-line'],['文件','ri:file-text-line'],
    ['日历','ri:calendar-2-line'],['时间','ri:time-line'],['定位','ri:map-pin-line'],['客服','ri:customer-service-2-line'],
    ['审核','ri:checkbox-circle-line'],['警告','ri:alarm-warning-line'],['锁定','ri:lock-line'],['安全','ri:shield-check-line'],
    ['配置','ri:tools-line'],['应用','ri:apps-2-line'],['标签','ri:price-tag-3-line'],['收藏','ri:star-line'],
    ['图片','ri:image-line'],['视频','ri:video-line'],['直播','ri:live-line'],['帮助','ri:question-line']
  ].map(([label,value])=>({label,value}))
  const rules:FormRules={type:[{required:true}],name:[{required:true,message:'请输入唯一名称'}],title:[{required:true,message:'请输入显示名称'}],path:[{validator:(_r,v,cb)=>form.type!=='BUTTON'&&!v?cb(new Error('请输入路由路径')):cb()}],authMark:[{validator:(_r,v,cb)=>form.type==='BUTTON'&&!/^[a-z][a-z0-9-]*:[a-z][a-z0-9-]*:[a-z][a-z0-9-]*$/.test(v||'')?cb(new Error('请输入 模块:资源:动作 格式')):cb()}]}
  function init(){const row=props.editData;if(row?.id){Object.assign(form,{parentId:row.parentId??null,type:row.type||'MENU',name:row.name||'',path:row.path||'',component:row.component||'',title:row.meta?.title||row.title||'',icon:row.meta?.icon||'',authMark:row.authMark||row.meta?.authMark||'',sortNo:row.sortNo||0,hidden:row.meta?.isHide??false,enabled:row.enabled??true,keepAlive:row.meta?.keepAlive??false})}else Object.assign(form,empty());nextTick(()=>formRef.value?.clearValidate())}
  async function submit(){if(!formRef.value)return;await formRef.value.validate();emit('submit',{...form,id:props.editData?.id});visible.value=false}
</script>
