import 'package:echo_nlu/features/echo_detail/models/echo_detail.dart';


enum EchoDetailStatus {
  initial,
  loading,
  success,
  failure,
}


class EchoDetailState{
 final  EchoDetail? echoDetail;
 final EchoDetailStatus status;
 final bool isplayingAudio;
 final String? errorMessage;

  const EchoDetailState({
    this.echoDetail,
    this.status = EchoDetailStatus.initial,
    this.isplayingAudio = false,
    this.errorMessage,
  });


  EchoDetailState copyWith({
    EchoDetail? echoDetail,
    EchoDetailStatus? status,
    bool? isplayingAudio,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EchoDetailState(
      echoDetail: echoDetail ?? this.echoDetail,
      status: status ?? this.status,
      isplayingAudio: isplayingAudio ?? this.isplayingAudio,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),

    );
  }
}