
#!/usr/bin/python
#coding: utf-8  

import smtplib
from email.mime.multipart import MIMEMultipart    
from email.mime.text import MIMEText    
from email.mime.image import MIMEImage    

sender = 'shaojuan.wang@polydata.com.cn'
receivers = ['shaojuan.wang@polydata.com.cn']

message = """From: From Person <shaojuan.wang@polydata.com.cn>
To: To Person <shaojuan.wang@polydata.com.cn>
Subject: SMTP e-mail test

This is a test e-mail message.
!!!!!!!!!!!!!!!!!!!!
22222222222222222
3333333333333333333333333
"""
username = 'shaojuan.wang@polydata.com.cn'
password = 'Juanjuan88'   
msgRoot = MIMEMultipart('related')    
msgRoot['Subject'] = 'test message'    
    
# msgText = MIMEText('<b>Some <i>HTML</i> text</b> and an image.<br><img src="cid:image1"><br>good!','html','utf-8')    
# msgRoot.attach(msgText)    
    
# fp = open('//susan//girl.jpg', 'rb')    
# msgImage = MIMEImage(fp.read())    
# fp.close()    
    
# msgImage.add_header('Content-ID', '<image1>')    
# msgRoot.attach(msgImage)   

att = MIMEText(open('//susan//girl.jpg', 'rb').read(), 'base64', 'utf-8')    
att["Content-Type"] = 'application/octet-stream'    
att["Content-Disposition"] = 'attachment; filename="girl.jpg"'    
msgRoot.attach(att)    
#try:

smtp = smtplib.SMTP()    
smtp.connect('smtp.polydata.com.cn')    
smtp.login(username, password)    
smtp.sendmail(sender, receivers,msgRoot.as_string())         
print "Successfully sent email"


#except SMTPException:
#	print "Error: unable to send email"
