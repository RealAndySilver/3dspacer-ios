//
//  ServerCommunicator.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 10/07/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "ServerCommunicator.h"

@implementation ServerCommunicator
@synthesize dictionary,tag,caller,objectDic,resDic;
-(id)init {
    self = [super init];
    if (self) {
        tag = 0;
        caller = nil;
        webData = nil;
        theConnection = nil;
    }
    return self;
}
-(void)callServerWithMethod:(NSString*)method 
               andParameter:(NSString*)parameter{
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                             "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns=\"bot_api/1.0/\"\n"
                             "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n"
                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
                             "xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                             "<soapenv:Header/>\n"
                             "<soapenv:Body>\n"
                             "%@\n"
                             "</soapenv:Body>\n"
                             "</soapenv:Envelope>\n",parameter];
	//NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.ekoomedia.com.co/ekoobot3d/web/ws/bot_api?wsdl"]];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ekoomedia.com.co/ekoobot3d_test/web/ws/bot_api?wsdl"]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ekoobot.com/web/ws/bot_api?wsdl"]];


    NSString *soapAction=[NSString stringWithFormat:@"http://bot_api/1.0/"];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];  
	NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];          
	[theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];       
	[theRequest addValue: soapAction forHTTPHeaderField:@"SOAPAction"];
	[theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	dictionary = [[NSDictionary alloc]init];
	if(theConnection) {
		webData = [NSMutableData data];
	}
	else {
		NSLog(@"theConnection is NULL");
	}
}


//Implement the NSURL and XMLParser protocols
#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[webData setLength:0];
	NSLog(@"didReceiveresponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[webData appendData:data];
	NSLog(@"didReceiveData");
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"didFailWithError");
    if ([caller respondsToSelector:@selector(receivedDataFromServerWithError:)]) {
        [caller performSelector:@selector(receivedDataFromServerWithError:) withObject:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
	NSLog(@"Todos los datos recibidos");
    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];

    NSDictionary *dictionary1 = [XMLReader dictionaryForXMLString:theXML error:nil];
    

    
    if ([caller respondsToSelector:@selector(receivedDataFromServer:)]) {
        NSDictionary * dictionary2=[[[[dictionary1 objectForKey:@"SOAP-ENV:Envelope"]objectForKey:@"SOAP-ENV:Body"]objectForKey:@"ns1:getDataResponse"]objectForKey:@"return"];
        resDic=[[NSMutableDictionary alloc]initWithDictionary:dictionary2];
        //NSLog(@"xml %@",resDic);
        NSLog(@"xml %@",dictionary1);
        [caller performSelector:@selector(receivedDataFromServer:) withObject:self];
    }
    else if ([caller respondsToSelector:@selector(receivedDataFromServerRegister:)]) {
        //resDic=[[NSMutableDictionary alloc]initWithDictionary:dictionary2];
        //NSLog(@"xml %@",resDic);
        NSDictionary * dictionary2=[[dictionary1 objectForKey:@"SOAP-ENV:Envelope"]objectForKey:@"SOAP-ENV:Body"];
        resDic=[[NSMutableDictionary alloc]initWithDictionary:dictionary2];
        NSLog(@"xml %@",dictionary1);
        [caller performSelector:@selector(receivedDataFromServerRegister:) withObject:self];
    }
}

@end
