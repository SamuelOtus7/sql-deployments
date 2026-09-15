-- ============================================================
-- BASELINE: dbo.vw_dados_aparelhos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dados_aparelhos]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_dados_aparelhos]
as
select  
	users.usr_cd_usuario as CodigoUsuario, 
	users.usr_nm_usuario as NomeUsuario, 
	ultimo.Ultimo as UltimoAcesso, 
	UPPER(manufacturer) as Fabricante, 
	UPPER(model) as Modelo, 
	platform as Plataforma, 
	version as VersaoSO, 
	case when isnull(versionAppAcaoGPS,versionApp) = '' then '< 1.011' else isnull(versionAppAcaoGPS,versionApp)  end as VersaoDA, 
	clientes.cli_ds_nome as Tenant, 
	clientes.cli_cd_codigo_cliente as TenantId, 
	UltimaRota, 
	Base, 
	case when isnull(versionAppAcaoGPS,versionApp) = versao.prm_ds_valor then 'App atualizado' else 'Atualização pendente' end as AtualizacaoNecessaria 
	,agp_ds_uuid as CodAparelhoDadosAparelho
from 
	( 
		select  
			b.agp_ds_version_app as versionAppAcaoGPS 
			,a.* 
		from 
			( 
				select 
					*   
					,row_number() over(partition by CodigoUsuario order by DataHoraColeta desc) rank  
				from 
					tb_Dados_Aparelhos with(nolock)
				--where CodigoUsuario= 4026 
			) as a 
			left join  
			( 
				select  
					* 
					,row_number() over(partition by agp_cd_usuario order by agp_dh_data_hora desc) rank  
				from 
					TB_ACAO_GPS with(nolock)
				where 
					agp_ds_version_app is not null  
			) as b on a.CodigoUsuario = b.agp_cd_usuario 
					and a.rank = b.rank 
		where 
			a.rank = 1 
	) as dados 
	join ( 
			select 
				CodigoUsuario,  
				max(Timestamp) as Ultimo  
			from 
				tb_Dados_Aparelhos with(nolock)
			group by 
				CodigoUsuario 
		) as ultimo on dados.CodigoUsuario = ultimo.CodigoUsuario 
	inner join tb_usuario as users with(nolock) on dados.CodigoUsuario = users.usr_cd_usuario 
	left join tb_clientes as clientes with(nolock) on users.cli_cd_codigo_cliente = clientes.cli_cd_codigo_cliente 
	left join ( 
				select 
					Motorista, 
					usuarioda as UsuarioDA,
				   max(base) as base, 
				   max(DataReferencia) as UltimaRota 
				from 
					( 
						select 
							rotas.NomeMotorista as Motorista, 
						   rotas.UsuarioDA,
						   rotas.ServiceCenter as Base, 
						   rotas.DataReferencia 
						from 
							tb_ml_rotas as rotas with(nolock)
							join ( 
								  select 
										NomeMotorista, 
										max(Id) as Id  
								  from 
										tb_ml_rotas with(nolock)  
								  group by 
										NomeMotorista 
							   ) as ultimo  on rotas.Id = ultimo.Id 
 
							union all 
 
							select 
								motoristas.Nome as Motorista, 
								usuarioirisys,
							    stations.NomeStation as Base, 
							    rotas.DataReferencia 
							from 
								tb_spe_rotas_v4 as rotas with(nolock) 
								join ( 
										select 
											IdMotorista, 
											max(Id) as Id  
										from 
											tb_spe_rotas_v4  
										group by 
											IdMotorista 
								) as ultimo  on rotas.Id = ultimo.Id 
								inner join tb_spe_station as stations with(nolock)  on rotas.IdStation = stations.IdStation 
								inner join tb_spe_motoristas as motoristas with(nolock) on rotas.IdMotorista = motoristas.IdMotorista 
					) as base 
					group by 
						Motorista ,usuarioda
	) as base on users.usr_cd_usuario = base.UsuarioDA 
	join tb_parametros as versao with(nolock) on versao.prm_nm_parametro = 'Versão do App' 
	left join tb_acao_gps as acao_Gps with(nolock) on agp_cd_usuario = usr_cd_usuario
where 
	users.usr_ds_email not like '%@otus7.com%' 
	and dados.rank = 1 
	and users.usr_in_ativo = 1
	and base.UltimaRota >= cast(getdate()-45 as date)


GO
