import 'package:um_verify_flutter/generated/json/base/json_convert_content.dart';

class UmVerifyResultEntity with JsonConvert<UmVerifyResultEntity> {
	late String msg;
	///成功时 resultCode:600000 其他情况时"resultCode"值请参考 https://developer.umeng.com/docs/143070/detail/144788
	late String resultCode;
	late String requestId;

	UmVerifyResultEntity();

	UmVerifyResultEntity.fromJson(Map map) {
		msg = map['msg'] ?? '';
		resultCode = map['resultCode'];
		requestId = map['requestId'] ?? '';
	}

	@override
  String toString() {
    return '[msg: $msg, resultCode: $resultCode, requestId: $requestId]';
  }
}
