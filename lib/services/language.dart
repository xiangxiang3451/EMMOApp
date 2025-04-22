
class I18N {
  // 定义不同语言下的文本字典
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home': 'Home',
      'talk': 'Talk',
      'games': 'Games',
      'relax': 'Relax',
      'settings': 'Settings',
      'export_pdf': 'Export PDF',
      'language': 'Language',
      'exit': 'EXIT',
      'enter_your_feelings': 'Enter your feelings',
      'send': 'Send',
      'continue': 'Continue',
      'end_and_summarize': 'End & Summarize',
      'restart_conversation': 'Restart Conversation',
      'select_sound': 'Select Sound',
      'select_timer': 'Select Timer',
      'custom_time': 'Custom Timer (minutes)',
      'start': 'Start',
      'pause': 'Pause',
      'resume': 'Resume',
      'remaining_time': 'Remaining Time: ',
      'please_select_sound': 'Please select a sound first',
      'invalid_time': 'Please enter a valid timer value',
      'unable_to_leave': 'Timer is running, unable to leave the page',
    },
    'zh': {
      'home': '首页',
      'talk': '谈话',
      'games': '游戏',
      'relax': '放松',
      'settings': '设置',
      'export_pdf': '导出 PDF',
      'language': '语言',
      'exit': '退出',
      'enter_your_feelings': '输入你的感受',
      'send': '发送',
      'continue': '继续',
      'end_and_summarize': '结束并总结',
      'restart_conversation': '重新开始对话',
      'select_sound': '选择声音',
      'select_timer': '选择倒计时',
      'custom_time': '自定义倒计时时间（分钟）',
      'start': '开始',
      'pause': '暂停',
      'resume': '继续',
      'remaining_time': '剩余时间: ',
      'please_select_sound': '请先选择一个声音',
      'invalid_time': '请输入有效的倒计时时间',
      'unable_to_leave': '倒计时运行中，无法退出页面',
    }
  };

  // 当前语言的设置，默认为英语
  static String _currentLanguage = 'en';

  // 获取当前语言的文本
  static String translate(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }

  // 设置当前语言
  static void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
  }

  // 获取当前语言代码
  static String get currentLanguage => _currentLanguage;
  
}
