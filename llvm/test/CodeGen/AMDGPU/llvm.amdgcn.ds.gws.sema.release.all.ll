; RUN: not llc -mtriple=amdgcn-mesa-mesa3d -mcpu=tahiti -o - < %s 2>&1 | FileCheck -enable-var-scope -check-prefix=GFX6ERR %s
; RUN: llc -mtriple=amdgcn-mesa-mesa3d -mcpu=hawaii -o - -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,LOOP %s
; RUN: llc -mtriple=amdgcn-mesa-mesa3d -mcpu=fiji -o - -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,LOOP,GFX8 %s
; RUN: llc -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx900 -o - -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,NOLOOP %s
; RUN: llc -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx1010 -o - -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,NOLOOP,GFX10 %s

; GFX6ERR: LLVM ERROR: Cannot select: intrinsic %llvm.amdgcn.ds.gws.sema.release.all

; GCN-LABEL: {{^}}gws_sema_release_all_offset0:
; NOLOOP-DAG: s_mov_b32 m0, 0{{$}}
; NOLOOP: ds_gws_sema_release_all gds{{$}}

; LOOP: s_mov_b32 m0, 0{{$}}
; LOOP: [[LOOP:BB[0-9]+_[0-9]+]]:
; LOOP-NEXT: s_setreg_imm32_b32 hwreg(HW_REG_TRAPSTS, 8, 1), 0
; GFX8-NEXT: s_nop 0
; LOOP-NEXT: ds_gws_sema_release_all gds
; LOOP-NEXT: s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; LOOP-NEXT: s_getreg_b32 [[GETREG:s[0-9]+]], hwreg(HW_REG_TRAPSTS, 8, 1)
; LOOP-NEXT: s_cmp_lg_u32 [[GETREG]], 0
; LOOP-NEXT: s_cbranch_scc1 [[LOOP]]
define amdgpu_kernel void @gws_sema_release_all_offset0(i32 %val) #0 {
  call void @llvm.amdgcn.ds.gws.sema.release.all(i32 0)
  ret void
}

declare void @llvm.amdgcn.ds.gws.sema.release.all(i32) #0

attributes #0 = { convergent inaccessiblememonly nounwind }
