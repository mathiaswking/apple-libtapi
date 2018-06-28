; NOTE: Assertions have been autogenerated by update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s
target datalayout = "p:32:32"

; Check some past-the-end subtleties.

@opte_a = global i32 0
@opte_b = global i32 0

; Comparing base addresses of two distinct globals. Never equal.

define zeroext i1 @no_offsets() {
; CHECK-LABEL: @no_offsets(
; CHECK:         ret i1 false
;
  %t = icmp eq i32* @opte_a, @opte_b
  ret i1 %t
}

; Comparing past-the-end addresses of two distinct globals. Never equal.

define zeroext i1 @both_past_the_end() {
; CHECK-LABEL: @both_past_the_end(
; CHECK:         ret i1 icmp eq (i32* getelementptr inbounds (i32, i32* @opte_a, i32 1), i32* getelementptr inbounds (i32, i32* @opte_b, i32 1))
;
  %x = getelementptr i32, i32* @opte_a, i32 1
  %y = getelementptr i32, i32* @opte_b, i32 1
  %t = icmp eq i32* %x, %y
  ret i1 %t
  ; TODO: refine this
}

; Comparing past-the-end addresses of one global to the base address
; of another. Can't fold this.

define zeroext i1 @just_one_past_the_end() {
; CHECK-LABEL: @just_one_past_the_end(
; CHECK:         ret i1 icmp eq (i32* getelementptr inbounds (i32, i32* @opte_a, i32 1), i32* @opte_b)
;
  %x = getelementptr i32, i32* @opte_a, i32 1
  %t = icmp eq i32* %x, @opte_b
  ret i1 %t
}

; Comparing base addresses of two distinct allocas. Never equal.

define zeroext i1 @no_alloca_offsets() {
; CHECK-LABEL: @no_alloca_offsets(
; CHECK:         ret i1 false
;
  %m = alloca i32
  %n = alloca i32
  %t = icmp eq i32* %m, %n
  ret i1 %t
}

; Comparing past-the-end addresses of two distinct allocas. Never equal.

define zeroext i1 @both_past_the_end_alloca() {
; CHECK-LABEL: @both_past_the_end_alloca(
; CHECK:         [[M:%.*]] = alloca i32
; CHECK-NEXT:    [[N:%.*]] = alloca i32
; CHECK-NEXT:    [[X:%.*]] = getelementptr i32, i32* [[M]], i32 1
; CHECK-NEXT:    [[Y:%.*]] = getelementptr i32, i32* [[N]], i32 1
; CHECK-NEXT:    [[T:%.*]] = icmp eq i32* [[X]], [[Y]]
; CHECK-NEXT:    ret i1 [[T]]
;
  %m = alloca i32
  %n = alloca i32
  %x = getelementptr i32, i32* %m, i32 1
  %y = getelementptr i32, i32* %n, i32 1
  %t = icmp eq i32* %x, %y
  ret i1 %t
  ; TODO: refine this
}

; Comparing past-the-end addresses of one alloca to the base address
; of another. Can't fold this.

define zeroext i1 @just_one_past_the_end_alloca() {
; CHECK-LABEL: @just_one_past_the_end_alloca(
; CHECK:         [[M:%.*]] = alloca i32
; CHECK-NEXT:    [[N:%.*]] = alloca i32
; CHECK-NEXT:    [[X:%.*]] = getelementptr i32, i32* [[M]], i32 1
; CHECK-NEXT:    [[T:%.*]] = icmp eq i32* [[X]], [[N]]
; CHECK-NEXT:    ret i1 [[T]]
;
  %m = alloca i32
  %n = alloca i32
  %x = getelementptr i32, i32* %m, i32 1
  %t = icmp eq i32* %x, %n
  ret i1 %t
}