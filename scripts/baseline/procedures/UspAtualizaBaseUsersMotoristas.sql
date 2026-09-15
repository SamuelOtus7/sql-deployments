-- ============================================================
-- BASELINE: dbo.UspAtualizaBaseUsersMotoristas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaBaseUsersMotoristas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[UspAtualizaBaseUsersMotoristas] 
 
as 
 
update users 
set usr_ds_base = motoristas.base 
from tb_usuario as users 
	inner join ( 
				select users.usr_cd_usuario, 
					   max(motoristas.base) as Base 
				from ( 
 
						select  rotas.NomeMotorista, 
                                cli_cd_codigo_cliente idtransportadora,
								max(ServiceCenter) as base 
						from tb_ml_rotas as rotas with(nolock) 
                        left join tb_clientes as cli
                        on rotas.idtransportadora = cli.cli_id_logistics

							inner join ( 
											select NomeMotorista, 
												   max(DataReferencia) as DataReferencia 
											from tb_ml_rotas 
											where ServiceCenter is not null 
											group by NomeMotorista 
									   ) as ultimo 
								on rotas.NomeMotorista = ultimo.NomeMotorista 
								and rotas.DataReferencia = ultimo.DataReferencia 
                        where cli_cd_codigo_cliente <> 7 
						group by cli_cd_codigo_cliente, rotas.NomeMotorista 
 
						union all 
 
						select  m.NomeMotorista, 
                                 cli_cd_codigo_cliente idtransportadora,
								max(stations.NomeStation) as base 
						from tb_spe_rotas_v4 rotas with(nolock) 
                        left join tb_clientes as cli
                        on rotas.idtransportadora = cli.cli_id_logistics
								inner join ( 
											select IdMotorista, 
												   max(DataReferencia) as DataReferencia 
											from tb_spe_rotas_v4 
											group by IdMotorista 
									   ) as ultimo 
								on rotas.IdMotorista = ultimo.IdMotorista 
								and rotas.DataReferencia = ultimo.DataReferencia 
								join tb_spe_motoristas m with(nolock) on rotas.IdMotorista = m.IdMotorista 
								left join tb_spe_station as stations on rotas.IdStation = stations.IdStation 
						group by cli_cd_codigo_cliente, m.NomeMotorista 
					) as motoristas 
					inner join tb_usuario as users 
					on motoristas.NomeMotorista = users.usr_nm_usuario 
                    and motoristas.idtransportadora = users.cli_cd_codigo_cliente
				where users.usr_in_motorista = 1 
				group by users.usr_cd_usuario 
		) as motoristas 
	on users.usr_cd_usuario = motoristas.usr_cd_usuario 
 
GO
