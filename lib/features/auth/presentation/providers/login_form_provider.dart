import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:formz/formz.dart";
import "package:teslo_shop/features/auth/presentation/providers/auth_provider.dart";
import "package:teslo_shop/features/shared/shared.dart";


//!3 - Como lo consumimos StateNotifierProvider que es lo que se consume fuera.

//autodispose es recomendable para que cada vez que cambiemos  se limpien los campos
final loginFormProvider = StateNotifierProvider.autoDispose<LoginFormNotifier,LoginFormState>((ref) {

  

  final loginUserCalback= ref.watch(authProvider.notifier).loginUser;

  return LoginFormNotifier(loginUserCallBack:loginUserCalback);
});

//! 1 Crear State de este provider
//Definimos nuestro formState
class LoginFormState {
  //Transaccion verifica si ha hecho el envio
  final bool isPosting;
  //Verifica cuando ya ha hecho clic en ingresar
  final bool isFormPosted;
  final bool isValid;
  final Email email;
  final Password password;
//Construimos constructor tenemos datos pure de nuestras clases personalizadas
  LoginFormState({
    this.isPosting = false, 
    this.isFormPosted = false, 
    this.isValid = false, 
    this.email = const Email.pure(), 
    this.password = const Password.pure()});

    
  //Sobreescribimos to String
    @override
  String toString() {
    
    return ''' 
    isPosting:$isPosting
    isFormPosted:$isFormPosted
    isValid:$isValid
    email:$email
    password:$password
    ''';
  }


  //Copywith para cambiar el estado

  LoginFormState copywith({
     bool? isPosting,
     bool? isFormPosted,
     bool? isValid,
     Email? email,
     Password? password,
}) => LoginFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    email: email ?? this.email,
    password: password ?? this.password
  );


}
//! 2 Como implementamos un notifier
//Como manejamos los datos
class LoginFormNotifier extends StateNotifier<LoginFormState>  {

  final Function(String,String) loginUserCallBack;
  LoginFormNotifier({required this.loginUserCallBack}): super(LoginFormState());
  

  onEmailChange(String value){
    final newEmail = Email.dirty(value);
    state = state.copywith( isValid: Formz.validate([newEmail,state.password]), email:newEmail );
  }

  onPasswordChange(String value){
    final newPass = Password.dirty(value);
    state = state.copywith( isValid: Formz.validate([newPass,state.email]), password:newPass );
  }

  onFormSubmit() async{
    _touchEveryField();

    if ( !state.isValid ) return;

    state = state.copywith(
      isPosting: true
    );

    await loginUserCallBack(state.email.value, state.password.value);

    state = state.copywith(
      isPosting: false
    );
  }

  _touchEveryField(){
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copywith(
      isFormPosted: true,
      email:email,
      password: password,
      isValid: Formz.validate([email,password])
    );
  }
}


