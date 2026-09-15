-- ============================================================
-- BASELINE: dbo.vw_motoristas_dois_aparelhos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_motoristas_dois_aparelhos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view  [dbo].[vw_motoristas_dois_aparelhos] as 

select 
	RegistroAparelho.data,
	rotas.idtransportadora,
	rotas.idrota,
	usu.usr_cd_usuario,
	usu.usr_nm_usuario,
	RegistroAparelho.uuid,
	manufacturer as Aparelho,	
	model as Modelo,
	QtdRegistros

from tb_usuario as usu with(nolock)
inner join 
		(
			select registro.*
			from (
					select distinct 
					 cast(rgp_dh_data_hora	as date) as data
					,rgp_cd_usuario as CodigoUsuario
					,rgp_ds_uuid	as uuid
					,count(*) QtdRegistros
					from tb_registro_gps nolock
					where cast(rgp_dh_data_hora	as date) between '2024-01-16'and '2024-01-30'
					group by rgp_cd_usuario,rgp_ds_uuid, cast(rgp_dh_data_hora	as date) 
					--having count(*) > 20 
			) as registro
			inner join
						(
						select
							data
							,CodigoUsuario
							,count(*) qtd

						from
							(
								select distinct 
								 cast(rgp_dh_data_hora	as date) as data
								,rgp_cd_usuario CodigoUsuario
								,rgp_ds_uuid uuid	
								from tb_registro_gps nolock
								where cast(rgp_dh_data_hora	as date) between '2024-01-16'and  '2024-01-30'
							) as a
						group by  data,CodigoUsuario
						having COUNT(*) > 1
						) duplicados
			on registro.data = duplicados.data
			and  registro.CodigoUsuario = duplicados.CodigoUsuario
		) as RegistroAparelho
on usu.usr_cd_usuario = RegistroAparelho.CodigoUsuario

left join (
			select  
				max(Timestamp) as ultimadata
				,CodigoUsuario
				,manufacturer	
				,model
				,uuid
			from[dbo].[tb_dados_aparelhos] nolock
			group by CodigoUsuario
				,manufacturer	
				,model
				,uuid
			) as DadosAparelho
on RegistroAparelho.CodigoUsuario = DadosAparelho.CodigoUsuario
and RegistroAparelho.uuid = DadosAparelho.uuid

left join tb_ml_rotas as rotas with(nolock)
on RegistroAparelho.data = rotas.DataReferencia
and RegistroAparelho.CodigoUsuario = rotas.UsuarioDA
 


GO
