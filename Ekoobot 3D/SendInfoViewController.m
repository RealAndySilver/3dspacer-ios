//
//  SendInfoViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 17/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "SendInfoViewController.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"

@interface SendInfoViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) NSDictionary *messageDic;
@end

@implementation SendInfoViewController
@synthesize nombreProyecto,usuario,contrasena,proyectoID;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    if ([self.userType isEqualToString:@"sellers"]) {
        methodName=@"setRegister";
        self.navigationItem.title=@"Enviar Proyecto";
    }
    else{
        methodName=@"sendSuggest";
        self.navigationItem.title=@"Recomendar Proyecto";
    }
    
    nombreTF.delegate=self;
    emailTF.delegate=self;
    comentarioTV.delegate=self;
    //server=[[ServerCommunicator alloc]init]; //************************************* Corregir Estooooo ***************************//
    //server.caller=self;
    tituloProyectoLabel.text=nombreProyecto;
    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    lang = [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:langID];
    NSLog(@"Language is %@",lang);
    //FileSaver *file=[[FileSaver alloc]init];
    //NSDictionary *pendingDic=[file getDictionary:@"SendInfoDictionary"];
    /*if ([[pendingDic objectForKey:@"SentState"]isEqualToString:@"false"]) {
        nombreTF.text=[pendingDic objectForKey:@"Name"];
        emailTF.text=[pendingDic objectForKey:@"Email"];
        comentarioTV.text=[pendingDic objectForKey:@"Comment"];
        [self pendingAlert];
    }*/
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    initialFrame=container.frame;
    finalFrame=CGRectMake(161, 50, 710, 494);
}
- (void)didReceiveMemoryWarning
{
    //[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark actions
-(IBAction)send:(id)sender{
    NSLog(@"--------------> %@ %@",usuario,contrasena);
    if ([self.userType isEqualToString:@"sellers"]) {
        
        if (![nombreTF.text isEqualToString:@""]) {
            if (![emailTF.text isEqualToString:@""]) {
                if (![comentarioTV.text isEqualToString:@""]) {
                    NSLog(@"Usuario :%@ \nContrasena : %@",usuario,contrasena);
                    /*NSString *loginData=[NSString stringWithFormat:@"%@~%@~%@",usuario,contrasena,[IAmCoder dateString]];
                    NSString *params=[NSString stringWithFormat:@"<ns:setRegister><data>%@</data><token>%@</token><language>%@</language><register><name>%@</name><email>%@</email><comments>%@</comments><project>%@</project></register></ns:setRegister>",loginData,[IAmCoder hash256:loginData],lang,nombreTF.text,emailTF.text,comentarioTV.text,proyectoID];
                    [server callServerWithMethod:@"" andParameter:params];*/
                    [self sendInfoToServer];
                    [self resignKeyboard];
                }
                else{
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Debe agregar un comentario." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Debe ingresar un correo electrónico." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Debe ingresar un nombre." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else{
        if (![nombreTF.text isEqualToString:@""]) {
            if (![emailTF.text isEqualToString:@""]) {
                if (![comentarioTV.text isEqualToString:@""]) {
                    NSLog(@"Usuario :%@ \nContrasena : %@",usuario,contrasena);
                    [self sendInfoToServer];
                    /*NSString *loginData=[NSString stringWithFormat:@"%@~%@~%@",usuario,contrasena,[IAmCoder dateString]];
                    NSString *params=[NSString stringWithFormat:@"<ns:sendSuggest><data>%@</data><token>%@</token><language>%@</language><register><name>%@</name><email>%@</email><comments>%@</comments><project>%@</project></register></ns:sendSuggest>",loginData,[IAmCoder hash256:loginData],lang,nombreTF.text,emailTF.text,comentarioTV.text,proyectoID];
                    [server callServerWithMethod:@"" andParameter:params];*/
                }
                else{
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:NSLocalizedString(@"AgregarComentario", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:NSLocalizedString(@"AgregarEmail", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:NSLocalizedString(@"AgregarNombre", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    /*NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setObject:usuario forKey:@"Username"];
    [dictionary setObject:contrasena forKey:@"Password"];
    [dictionary setObject:lang forKey:@"Language"];
    [dictionary setObject:nombreTF.text forKey:@"Name"];
    [dictionary setObject:emailTF.text forKey:@"Email"];
    [dictionary setObject:comentarioTV.text forKey:@"Comment"];
    [dictionary setObject:proyectoID forKey:@"ProjectID"];
    [dictionary setObject:@"false" forKey:@"SentState"];
    [dictionary setObject:methodName forKey:@"MethodName"];
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withName:@"SendInfoDictionary"];
    NSLog(@"Ditcionary dude %@",[file getDictionary:@"SendInfoDictionary"]);*/
}

-(NSString *)generateJSONString {
    //Create JSON string with user info
    NSDictionary *userDic = @{@"name": nombreTF.text,
                              @"email" : emailTF.text,
                              @"comments" : comentarioTV.text};
    NSDictionary *projectDic = @{@"id": @([self.proyectoID intValue])};
    
    NSDictionary *finalInfoDic = @{@"user": userDic,
                                   @"project" : projectDic};
    
    self.messageDic = finalInfoDic;
    //NSArray *finalInfoArray = @[finalInfoDic];
   
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"MessagesStoredDic"][@"MessagesStoredArray"]) {
        NSMutableArray *messagesArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"MessagesStoredDic"][@"MessagesStoredArray"]];
        [messagesArray addObject:self.messageDic];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messagesArray
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Json String: %@", jsonString);
        return jsonString;
        
    } else {
        NSArray *messageArray = @[self.messageDic];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageArray
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Json String: %@", jsonString);
        return jsonString;
    }
}

-(void)sendInfoToServer {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"projectUser=%@", [self generateJSONString]];
    [serverCommunicator callServerWithPOSTMethod:@"sendProjects" andParameter:parameter httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)theMethodName {
    if ([theMethodName isEqualToString:@"sendProjects"]) {
        if (dictionary) {
            NSLog(@"Llego correctamente el diccionario de sendProject: %@", dictionary);
            if ([dictionary[@"success"] boolValue]) {
                /*NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
                [dictionary setObject:@"true" forKey:@"SentState"];
                FileSaver *file=[[FileSaver alloc]init];
                [file setDictionary:dictionary withName:@"SendInfoDictionary"];*/
                
                FileSaver *fileSaver = [[FileSaver alloc] init];
                [fileSaver setDictionary:@{@"MessagesStoredArray": @[]} withName:@"MessagesStoredDic"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProyectoEnviado", nil)
                                                                message:NSLocalizedString(@"ProyectoEnviadoExito", nil)
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil,nil];
                [alert show];
            }
            else{
                [self errorAlert];
            }
            
        } else {
            NSLog(@"La respuesta del sendPRojects fue Null");
        }
    } else {
        NSLog(@"Error en la respuesta del server");
    }
}

-(void)serverError:(NSError *)error {
    NSLog(@"Error en el server: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"MessagesStoredDic"][@"MessagesStoredArray"]) {
        NSLog(@"Ya exitía el arreglo de mensajes en file saver");
        NSMutableArray *messagesArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"MessagesStoredDic"][@"MessagesStoredArray"]];
        [messagesArray addObject:self.messageDic];
        [fileSaver setDictionary:@{@"MessagesStoredArray": messagesArray} withName:@"MessagesStoredDic"];
        
    } else {
        NSLog(@"No existía el arreglo de mensajes en file saver");
        NSArray *messagesStoredArray = @[self.messageDic];
        [fileSaver setDictionary:@{@"MessagesStoredArray": messagesStoredArray} withName:@"MessagesStoredDic"];
    }
}

-(IBAction)cancel:(id)sender{
    [self customLogoutAlert];
}
- (void)customLogoutAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CancelarEnvio", nil)
                                                    message:NSLocalizedString(@"CancelarEnvioSeguro", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancelar", nil)
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [self goBack];
    }
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
/*-(void)receivedDataFromServerRegister:(id)sender{
    //server=sender;
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setObject:@"true" forKey:@"SentState"];
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withName:@"SendInfoDictionary"];
    //NSLog(@"Resultado %@",server.resDic );
    NSString *tempMethod=[NSString stringWithFormat:@"ns1:%@Response",methodName];
    
    
    NSString *response=[[server.resDic objectForKey:tempMethod]objectForKey:@"return"]; ***************************************
    if ([response isEqualToString:@"success"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProyectoEnviado", nil)
                                                        message:NSLocalizedString(@"ProyectoEnviadoExito", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil,nil];
        [alert show];
    }
    else{
        [self errorAlert];
    }
}
-(void)receivedDataFromServerWithError:(id)sender{
    [self errorAlert];
}*/

-(void)errorAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:NSLocalizedString(@"ProyectoEnviadoNOExito", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Cancelar", nil)
                                          otherButtonTitles:nil,nil];
    [alert show];
}
-(void)pendingAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RegistroPendiente", nil)
                                                    message:NSLocalizedString(@"RegistroPendienteText", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil,nil];
    [alert show];
}
#pragma text delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    touchFlag=YES;
    [self animarHasta:finalFrame];
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    touchFlag=YES;
    [self animarHasta:finalFrame];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    touchFlag=NO;
    [self performSelector:@selector(delayed) withObject:nil afterDelay:0.01];
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    touchFlag=NO;
    [self performSelector:@selector(delayed) withObject:nil afterDelay:0.01];
}
-(void)delayed{
    if (!touchFlag) {
        [self animarHasta:initialFrame];
    }
}
#pragma mark animacion
-(void)animarHasta:(CGRect)hasta{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    container.frame=hasta;
    [UIView commitAnimations];
}
#pragma mark dismiss keyboard
-(void)resignKeyboard{
    [nombreTF resignFirstResponder];
    [emailTF resignFirstResponder];
    [comentarioTV resignFirstResponder];
}
#pragma mark rotation
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
@end
