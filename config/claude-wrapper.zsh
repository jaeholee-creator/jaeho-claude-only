# Claude Code with mode selector (v2.0 - 2026.02.12)
claude() {
  local claude_bin="/Users/jaeho/.local/bin/claude"

  # 인자가 있으면 기본 동작 (모드 선택 없이 바로 실행)
  if [ $# -gt 0 ]; then
    $claude_bin "$@"
    return
  fi

  # 인자가 없으면 모드 선택
  PS3=$'\n모드를 선택하세요 (숫자 입력): '

  local modes=(
    "Default (기본 - 모든 작업 확인)"
    "Accept Edits (편집 자동 승인) ⭐"
    "Plan Mode (읽기 전용 계획)"
    "Don't Ask (사전 승인만)"
    "Bypass Permissions ⚠️ (격리 환경)"
    "취소"
  )

  echo "\n🤖 Claude Code 모드 선택\n"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 Default: 모든 작업마다 확인 요청"
  echo "✏️  Accept Edits: 파일 편집 자동, 명령어만 확인 (추천)"
  echo "📝 Plan: 읽기 전용 분석 (수정 불가)"
  echo "🔒 Don't Ask: 사전 승인 목록만 사용"
  echo "⚠️  Bypass: 모든 권한 무시 (격리 환경만!)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

  select mode in "${modes[@]}"; do
    case $mode in
      "Default (기본 - 모든 작업 확인)")
        echo "\n✅ Default Mode로 실행합니다...\n"
        $claude_bin
        break
        ;;
      "Accept Edits (편집 자동 승인) ⭐")
        echo "\n✅ Accept Edits Mode로 실행합니다...\n"
        echo "   파일 편집: 자동 승인 ✅"
        echo "   Bash 명령어: 확인 요청 ⏳\n"
        $claude_bin --permission-mode acceptEdits
        break
        ;;
      "Plan Mode (읽기 전용 계획)")
        echo "\n✅ Plan Mode로 실행합니다...\n"
        echo "   읽기 전용: 파일 수정 불가 🔒\n"
        $claude_bin --permission-mode plan
        break
        ;;
      "Don't Ask (사전 승인만)")
        echo "\n✅ Don't Ask Mode로 실행합니다...\n"
        echo "   사전 승인된 작업만 자동 실행 🔒\n"
        $claude_bin --permission-mode dontAsk
        break
        ;;
      "Bypass Permissions ⚠️ (격리 환경)")
        echo "\n⚠️  경고! Bypass Permissions Mode는 매우 위험합니다."
        echo "   - 모든 권한 확인 무시"
        echo "   - Docker/VM 같은 격리 환경에서만 사용"
        echo "   - 프로덕션 환경에서는 절대 사용 금지\n"
        echo "정말 계속하시겠습니까? (yes/N): "
        read -r confirm
        if [[ $confirm == "yes" ]]; then
          echo "\n✅ Bypass Permissions Mode로 실행합니다...\n"
          $claude_bin --dangerously-skip-permissions
        else
          echo "\n❌ 취소되었습니다.\n"
          return 0
        fi
        break
        ;;
      "취소")
        echo "\n❌ 취소되었습니다.\n"
        return 0
        ;;
      *)
        echo "❌ 잘못된 선택입니다. 다시 선택해주세요."
        ;;
    esac
  done
}