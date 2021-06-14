<html>
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>QUEDROP APP</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <style type="text/css">
    body{
        font-family: Arial, sans-serif;
        font-size: 16px;
        line-height: 26px;
    }
    p{ margin: 0; }
  </style>
</head>
<body style="margin: 0; padding: 0;">
     <table align="" border="0" cellpadding="0" cellspacing="0" width="650" style="margin:0 auto;background-color:#f6f6f6;">    
     <tr>
      <td align="left" colspan="2" >
        <a style="display:block;padding-top: 10px;padding-bottom: 10px;" >
            QUEDROP APP
        </a>
        <hr style="border:1px solid #26A69A;">
      </td>  
     </tr>     
     <tr>
        <td bgcolor="#f6f6f6" style="padding: 40px 30px 40px 30px;" colspan="2">
             <table border="0" cellpadding="0" cellspacing="0" width="100%">              
                <tr>
                    <td colspan="2">Hi <?php echo $email['name']?>,</td>
                </tr>
                <tr>
                    <td style="padding: 20px 0 30px 0;">
                        <p> Your Login Details</p><br>
                        <p>Email: <b><?php echo $email['email'];?></b></p>
                        <p>Password : <b><?php echo $email['password'];?></b></p>
                    </td>
                 </tr>                
                 <tr><td><br><strong>Regards,</strong><br>QUEDROP APP.</td></tr>
             </table>
        </td>
     </tr>
     <tr>
        <td bgcolor="#848484" style="  border-top: 1px solid #26A69A;padding: 15px 0 15px 0;" valign="middle" colspan="2">
            <table border="0" cellpadding="0" cellspacing="0" width="100%" align="center">
                <tr>
                    <td align="center" width="25%">
                        <a href="#" style="color: #fff;font-size: 13px;font-weight:bold;  text-decoration: none;">© QUEDROP APP.</a>
                    </td>
                </tr>
            </table>
        </td>
     </tr>     
    </table>
</body>
</html>