-- ============================================================
-- BASELINE: dbo.UpsAtualizaNivelMotoristas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UpsAtualizaNivelMotoristas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UpsAtualizaNivelMotoristas] as 



declare @dataini date  = getdate()-1
declare @datafim date  = getdate()

--Comentado por Saulo Barros em 30/07/2026 pois está gerando vários registros na tb_usuario_hist por conta desse processo. Alinhado com Samuel para desativação por enquanto
/*
update 
	a
set 
	a.usr_ds_nivel_mot = nivelmotorista
from 
	tb_usuario as a
	inner join 
	(
		select 
			usuarioda
			,nivelmotorista
			,max(idrota) ultimoid 
		from 
			tb_ml_rotas
		where 
			excluido = 0 
			and datareferencia between @dataini and @datafim
			and nivelmotorista is not null
		group by 
			usuarioda
			,nivelmotorista
	) as b on a.usr_cd_usuario = b.usuarioda
where
	usr_in_ativo = 1
	and nivelmotorista <> isnull(usr_ds_nivel_mot,'')
*/
GO
