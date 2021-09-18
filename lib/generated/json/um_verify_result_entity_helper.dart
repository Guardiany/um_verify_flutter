import 'package:um_verify_flutter/um_verify_result_entity.dart';

umVerifyResultEntityFromJson(UmVerifyResultEntity data, Map<String, dynamic> json) {
	if (json['msg'] != null) {
		data.msg = json['msg'].toString();
	}
	if (json['resultCode'] != null) {
		data.resultCode = json['resultCode'].toString();
	}
	if (json['requestId'] != null) {
		data.requestId = json['requestId'].toString();
	}
	return data;
}

Map<String, dynamic> umVerifyResultEntityToJson(UmVerifyResultEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['msg'] = entity.msg;
	data['resultCode'] = entity.resultCode;
	data['requestId'] = entity.requestId;
	return data;
}