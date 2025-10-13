package com.inoi.urbanbreeze

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.TextView
import android.widget.ScrollView
import android.widget.LinearLayout
import android.view.ViewGroup
import android.graphics.Color
import android.util.TypedValue

class PermissionsRationaleActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // ScrollView 생성
        val scrollView = ScrollView(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(40, 40, 40, 40)
        }
        
        // LinearLayout 생성
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        
        // 제목
        val title = TextView(this).apply {
            text = "Urban Breeze가 Health Connect 데이터를 사용하는 이유"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setTextColor(Color.BLACK)
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 0, 40)
        }
        layout.addView(title)
        
        // 설명 추가
        addPermissionItem(layout, "🚴 사이클링 운동 기록", 
            "운동 시작/종료 시간과 운동 종류를 읽어와 주간/월간 성과를 추적하고 개인화된 운동 통계를 제공합니다.")
        
        addPermissionItem(layout, "❤️ 심박수 데이터", 
            "운동 중 실시간 심박수로 운동 강도를 분석하고 건강 상태를 추적합니다. 안전한 운동 범위 관리와 성과 개선에 활용됩니다.")
        
        addPermissionItem(layout, "⚡ 라이딩 속도", 
            "속도 데이터를 분석하여 평균/최고 속도 통계를 제공하고 성과 개선 인사이트를 제공합니다.")
        
        addPermissionItem(layout, "📍 이동 거리", 
            "이동 거리를 측정하여 운동 목표 달성도를 추적하고 주간/월간 라이딩 거리 통계를 제공합니다.")
        
        addPermissionItem(layout, "🔥 소모 칼로리", 
            "운동으로 소모한 총 칼로리와 활동 칼로리를 추적하여 정확한 에너지 소모량을 파악하고 맞춤형 피드백을 제공합니다.")
        
        addPermissionItem(layout, "🗺️ GPS 경로 데이터", 
            "사이클링 이동 경로를 지도에 시각화하고 고도 정보 및 경로 분석을 제공합니다.")
        
        // 개인정보 보호 안내
        val privacyNote = TextView(this).apply {
            text = "\n📌 개인정보 보호\n\nUrban Breeze는 사용자의 건강 데이터를 안전하게 보호합니다:\n\n" +
                   "• 모든 데이터는 안전하게 암호화되어 저장됩니다\n" +
                   "• 운동 기록 관리, 성과 추적, 개인화된 통계 제공에만 사용됩니다\n" +
                   "• 사용자의 명시적 동의 없이 제3자와 공유되지 않습니다\n" +
                   "• 언제든지 앱 설정에서 연동을 해제할 수 있습니다"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setTextColor(Color.DKGRAY)
            setPadding(0, 20, 0, 0)
            setLineSpacing(8f, 1.0f)
        }
        layout.addView(privacyNote)
        
        scrollView.addView(layout)
        setContentView(scrollView)
    }
    
    private fun addPermissionItem(layout: LinearLayout, title: String, description: String) {
        val titleView = TextView(this).apply {
            text = title
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            setTextColor(Color.BLACK)
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 20, 0, 8)
        }
        layout.addView(titleView)
        
        val descView = TextView(this).apply {
            text = description
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setTextColor(Color.DKGRAY)
            setPadding(0, 0, 0, 0)
            setLineSpacing(4f, 1.0f)
        }
        layout.addView(descView)
    }
}

