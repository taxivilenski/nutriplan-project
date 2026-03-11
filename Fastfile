# fastlane/Fastfile
# ─────────────────────────────────────────────────────────────────
# NutriPlan — fastlane lanes
#
# Установка:
#   gem install fastlane
#   fastlane supply init    # скачает текущий листинг из Play Console
#
# Использование:
#   fastlane android test           — запуск unit тестов
#   fastlane android build_dev      — devDebug APK
#   fastlane android deploy_internal — AAB → Internal Testing track
#   fastlane android deploy_prod    — Internal → Production (после ревью)
#   fastlane android update_listing — обновить только тексты/скриншоты
# ─────────────────────────────────────────────────────────────────

default_platform(:android)

platform :android do

  # ── Тесты ───────────────────────────────────────────────────
  lane :test do
    gradle(
      task:   "test",
      flavor: "dev",
      build_type: "Debug",
    )
  end

  # ── Dev APK (для тестирования) ───────────────────────────────
  lane :build_dev do
    gradle(
      task:        "assemble",
      flavor:      "dev",
      build_type:  "Debug",
      print_command: false,
    )
    UI.success("devDebug APK: #{lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]}")
  end

  # ── Internal Testing Track ────────────────────────────────────
  # Загружает подписанный prodRelease AAB в Internal Testing.
  # Требуется: KEYSTORE_*, PLAY_STORE_JSON_KEY (service account)
  lane :deploy_internal do
    # 1. Сборка и подпись
    gradle(
      task:        "bundle",
      flavor:      "prod",
      build_type:  "Release",
      print_command: false,
      properties: {
        "android.injected.signing.store.file"     => ENV["KEYSTORE_PATH"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias"      => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password"   => ENV["KEY_PASSWORD"],
      },
    )

    # 2. Загрузка в Play Console — Internal Testing
    upload_to_play_store(
      track:                  "internal",
      aab:                    lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH],
      json_key:               ENV["PLAY_STORE_JSON_KEY"],
      package_name:           "com.nutrition.app",
      skip_upload_apk:        true,
      skip_upload_metadata:   false,
      skip_upload_changelogs: false,
      skip_upload_images:     true,   # скриншоты — вручную или отдельным lane
      release_status:         "draft",
    )

    UI.success("AAB uploaded to Internal Testing ✅")
  end

  # ── Production ───────────────────────────────────────────────
  # Переводит существующий Internal релиз в Production.
  lane :deploy_prod do
    upload_to_play_store(
      track:            "internal",
      track_promote_to: "production",
      json_key:         ENV["PLAY_STORE_JSON_KEY"],
      package_name:     "com.nutrition.app",
      skip_upload_aab:      true,
      skip_upload_apk:      true,
      skip_upload_metadata: true,
    )
    UI.success("Promoted to Production ✅")
  end

  # ── Только обновить тексты/скриншоты ─────────────────────────
  lane :update_listing do
    upload_to_play_store(
      json_key:          ENV["PLAY_STORE_JSON_KEY"],
      package_name:      "com.nutrition.app",
      skip_upload_aab:   true,
      skip_upload_apk:   true,
      skip_upload_changelogs: true,
      metadata_path:     "./fastlane/metadata/android",
    )
    UI.success("Store listing updated ✅")
  end

end
