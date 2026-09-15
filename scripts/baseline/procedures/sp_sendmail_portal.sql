-- ============================================================
-- BASELINE: dbo.sp_sendmail_portal
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_sendmail_portal]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_sendmail_portal]
(
	@title as varchar(max),
	@mensagem as varchar(max),
	@importante as varchar(max),
	@destinatarios as varchar(max),
	@copia_oculta bit = 1,
	@anexo as varchar(max) = null
)

as	

declare @email as varchar(max),
	    @data as varchar(15),
	    @hora as varchar(15),
		@destinatarios_abertos as varchar(max)

set @destinatarios_abertos = case when @copia_oculta = 0 then @destinatarios else null end
set @destinatarios = case when @copia_oculta = 1 then @destinatarios else null end

set @data = convert(varchar,getdate(),103)
set	@hora = convert(varchar,getdate(),108)

set @email = 
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">
<head>
<!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->
<meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
<meta content="width=device-width" name="viewport"/>
<!--[if !mso]><!-->
<meta content="IE=edge" http-equiv="X-UA-Compatible"/>
<!--<![endif]-->
<title></title>
<!--[if !mso]><!-->
<!--<![endif]-->
<style type="text/css">
		body {
			margin: 0;
			padding: 0;
		}

		table,
		td,
		tr {
			vertical-align: top;
			border-collapse: collapse;
		}

		* {
			line-height: inherit;
		}

		a[x-apple-data-detectors=true] {
			color: inherit !important;
			text-decoration: none !important;
		}
	</style>
<style id="media-query" type="text/css">
		@media (max-width: 620px) {

			.block-grid,
			.col {
				min-width: 320px !important;
				max-width: 100% !important;
				display: block !important;
			}

			.block-grid {
				width: 100% !important;
			}

			.col {
				width: 100% !important;
			}

			.col>div {
				margin: 0 auto;
			}

			img.fullwidth,
			img.fullwidthOnMobile {
				max-width: 100% !important;
			}

			.no-stack .col {
				min-width: 0 !important;
				display: table-cell !important;
			}

			.no-stack.two-up .col {
				width: 50% !important;
			}

			.no-stack .col.num4 {
				width: 33% !important;
			}

			.no-stack .col.num8 {
				width: 66% !important;
			}

			.no-stack .col.num4 {
				width: 33% !important;
			}

			.no-stack .col.num3 {
				width: 25% !important;
			}

			.no-stack .col.num6 {
				width: 50% !important;
			}

			.no-stack .col.num9 {
				width: 75% !important;
			}

			.video-block {
				max-width: none !important;
			}

			.mobile_hide {
				min-height: 0px;
				max-height: 0px;
				max-width: 0px;
				display: none;
				overflow: hidden;
				font-size: 0px;
			}

			.desktop_hide {
				display: block !important;
				max-height: none !important;
			}
		}
	</style>
</head>
<body class="clean-body" style="margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #283C4B;">
<!--[if IE]><div class="ie-browser"><![endif]-->
<table bgcolor="#283C4B" cellpadding="0" cellspacing="0" class="nl-container" role="presentation" style="table-layout: fixed; vertical-align: top; min-width: 320px; Margin: 0 auto; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #283C4B; width: 100%;" valign="top" width="100%">
<tbody>
<tr style="vertical-align: top;" valign="top">
<td style="word-break: break-word; vertical-align: top;" valign="top">
<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color:#283C4B"><![endif]-->
<div style="background-color:#283C4B;">
<div class="block-grid" style="Margin: 0 auto; min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: #3AAEE0;">
<div style="border-collapse: collapse;display: table;width: 100%;background-color:#3AAEE0;">
<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#283C4B;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#3AAEE0"><![endif]-->
<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#3AAEE0;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:0px;"><![endif]-->
<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">
<div style="width:100% !important;">
<!--[if (!mso)&(!IE)]><!-->
<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:0px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;">
<!--<![endif]-->
<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 20px; padding-left: 20px; padding-top: 30px; padding-bottom: 20px; font-family: Arial, sans-serif"><![endif]-->
<div style="color:#FFFFFF;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:30px;padding-right:20px;padding-bottom:20px;padding-left:20px;">
<div style="line-height: 1.2; font-size: 12px; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; color: #FFFFFF; mso-line-height-alt: 14px;">
<p style="font-size: 24px; line-height: 1.2; text-align: center; word-break: break-word; font-family: lucida sans unicode, lucida grande, sans-serif; mso-line-height-alt: 29px; margin: 0;"><span style="font-size: 24px;">Notificação Athene7</span></p>
</div>
</div>
<!--[if mso]></td></tr></table><![endif]-->
<div align="center" class="img-container center autowidth fullwidth" style="padding-right: 0px;padding-left: 0px;">
<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr style="line-height:0px"><td style="padding-right: 0px;padding-left: 0px;" align="center"><![endif]--><img align="center" alt="Image" border="0" class="center autowidth fullwidth" src="https://imediato.app.br/assets/images/assets/mail.png" style="text-decoration: none; -ms-interpolation-mode: bicubic; border: 0; height: auto; width: 100%; max-width: 600px; display: block;" title="Image" width="600"/>
<!--[if mso]></td></tr></table><![endif]-->
</div>
<!--[if (!mso)&(!IE)]><!-->
</div>
<!--<![endif]-->
</div>
</div>
<!--[if (mso)|(IE)]></td></tr></table><![endif]-->
<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->
</div>
</div>
</div>
<div style="background-color:#283C4B;">
<div class="block-grid" style="Margin: 0 auto; min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: #FFFFFF;">
<div style="border-collapse: collapse;display: table;width: 100%;background-color:#FFFFFF;">
<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#283C4B;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#FFFFFF"><![endif]-->
<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#FFFFFF;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:10px;"><![endif]-->
<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">
<div style="width:100% !important;">
<!--[if (!mso)&(!IE)]><!-->
<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:0px; padding-bottom:10px; padding-right: 0px; padding-left: 0px;">
<!--<![endif]-->
<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 30px; padding-left: 30px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
<div style="color:#283C4B;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.5;padding-top:10px;padding-right:30px;padding-bottom:10px;padding-left:30px;">
<div style="line-height: 1.5; font-size: 12px; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; color: #283C4B; mso-line-height-alt: 18px;">
<p style="font-size: 16px; line-height: 1.5; word-break: break-word; font-family: lucida sans unicode, lucida grande, sans-serif; mso-line-height-alt: 24px; margin: 0;"><span style="font-size: 16px;"><strong>{{Título}}</strong></span></p>
</div>
</div>
<!--[if mso]></td></tr></table><![endif]-->
<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 30px; padding-left: 30px; padding-top: 10px; padding-bottom: 30px; font-family: Arial, sans-serif"><![endif]-->
<div style="color:#283C4B;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.5;padding-top:10px;padding-right:30px;padding-bottom:30px;padding-left:30px;">
<div style="line-height: 1.5; font-size: 12px; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; color: #283C4B; mso-line-height-alt: 18px;">
<p style="font-size: 12px; line-height: 1.5; word-break: break-word; font-family: lucida sans unicode, lucida grande, sans-serif; mso-line-height-alt: 18px; margin: 0;"> </p>
<p style="font-size: 14px; line-height: 1.5; word-break: break-word; font-family: lucida sans unicode, lucida grande, sans-serif; mso-line-height-alt: 21px; margin: 0;"><span style="font-size: 14px;">{{Mensagem}}</span></p>
</div>
</div>
<!--[if mso]></td></tr></table><![endif]-->
<!--[if (!mso)&(!IE)]><!-->
</div>
<!--<![endif]-->
</div>
</div>
<!--[if (mso)|(IE)]></td></tr></table><![endif]-->
<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->
</div>
</div>
</div>
<div style="background-color:#283C4B;">
<div class="block-grid" style="Margin: 0 auto; min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: transparent;">
<div style="border-collapse: collapse;display: table;width: 100%;background-color:transparent;">
<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#283C4B;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:transparent"><![endif]-->
<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:0px;"><![endif]-->
<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">
<div style="width:100% !important;">
<!--[if (!mso)&(!IE)]><!-->
<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:0px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;">
<!--<![endif]-->
<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top: 1px; padding-bottom: 1px; font-family: Arial, sans-serif"><![endif]-->
<div style="color:#3AAEE0;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:1px;padding-right:0px;padding-bottom:6px;padding-left:0px;">
<div style="line-height: 1.2; font-size: 12px; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; color: #3AAEE0; mso-line-height-alt: 14px;">
</div>
</div>
<!--[if mso]></td></tr></table><![endif]-->
<!--[if (!mso)&(!IE)]><!-->
</div>
<!--<![endif]-->
</div>
</div>
<!--[if (mso)|(IE)]></td></tr></table><![endif]-->
<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->
</div>
</div>
</div>
<div style="background-color:#283C4B;">
<div class="block-grid" style="Margin: 0 auto; min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: #FFFFFF;">
<div style="border-collapse: collapse;display: table;width: 100%;background-color:#FFFFFF;">
<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#283C4B;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#FFFFFF"><![endif]-->
<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#FFFFFF;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:0px;"><![endif]-->
<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">
<div style="width:100% !important;">
<!--[if (!mso)&(!IE)]><!-->
<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:0px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;">
<!--<![endif]-->
<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
<div style="color:#3AAEE0;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:0px;padding-bottom:10px;padding-left:0px;">
<div style="line-height: 1.2; font-size: 12px; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; color: #3AAEE0; mso-line-height-alt: 14px;">
<p style="font-size: 12px; line-height: 1.2; text-align: center; word-break: break-word; font-family: lucida sans unicode, lucida grande, sans-serif; mso-line-height-alt: 14px; margin: 0;"><span style="color: #b1b1b1;">Este e-mail foi gerado automaticamente, não é necessário respondê-lo.</span></p>
</div>
</div>
<!--[if mso]></td></tr></table><![endif]-->
<!--[if (!mso)&(!IE)]><!-->
</div>
<!--<![endif]-->
</div>
</div>
<!--[if (mso)|(IE)]></td></tr></table><![endif]-->
<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->
</div>
</div>
</div>
<!--[if (mso)|(IE)]></td></tr></table><![endif]-->
</td>
</tr>
</tbody>
</table>
<!--[if (IE)]></div><![endif]-->
</body>
</html>'

set @email = replace(replace(replace(replace(@email,'{{Título}}',@title),'{{data}}',@data),'{{hora}}',@hora),'{{Mensagem}}',@mensagem)
set @title = 'Notificação Athene7: ' + @title

 exec msdb.dbo.sp_send_dbmail

	   @copy_recipients = @destinatarios_abertos,
	   @blind_copy_recipients = @destinatarios,
	   @profile_name = 'Otus7Profile',     
	   @subject = @title, 
	   @body = @email,  
	   @body_format = 'html',
	   @importance = @importante,
	   @file_attachments = @anexo


GO
