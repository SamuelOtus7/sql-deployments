-- ============================================================
-- BASELINE: dbo.UspAtualzaUsuarioDA
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualzaUsuarioDA]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspAtualzaUsuarioDA] (
	@MesesRetroativo int = 1
)
as
begin

	
	------------------------------------------------------------
	-- ALTERA USUARIO DA EM QUE O NOME DO MOTORISTA É DIFERENTE DO NOME DO USUÁRIO
	------------------------------------------------------------

	--Adicionado por Saulo Barros em 27/03/2026
	--Verifica se teve rotas atreladas a um usuario da em que o nome é muito diferente do nome do motorista da rota
	--Se encontrar, altera o UsuarioDA para nulo para que a rotina processe novamente
	--Isso pode ocorrer pois temos casos em que a rota veio com um motorista e depois mudou
	declare @QtdeUsarioDAErrados int = (
										select
											count(1) qtde
											--r.UsuarioDA
											--,r.DriverId
											--,r.NomeMotorista
											--,u.usr_nm_usuario
											--,DIFFERENCE(r.NomeMotorista, u.usr_nm_usuario) as Score
										from
											tb_ml_rotas r with(nolock)
											join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario
										where
											DataReferencia >= cast(GETDATE()-15 as date)
											and r.Excluido = 0
											and r.StatusRota <> 'planned'
											and r.NomeMotorista <> '-' and r.NomeMotorista <> ''
											and DIFFERENCE(
												DBO.fn_remove_acentuacao(r.NomeMotorista), 
												DBO.fn_remove_acentuacao(LEFT(u.usr_nm_usuario, ISNULL(NULLIF(CHARINDEX('_', u.usr_nm_usuario) - 1, -1), LEN(u.usr_nm_usuario))))
											) <= 3
									)
	--colocamos por precaução para não atualizar muitas rotas esse limite
	if @QtdeUsarioDAErrados <= 100
	begin
		update
			r
		set
			r.UsuarioDA = null
		from
			tb_ml_rotas r with(nolock)
			join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario
		where
			DataReferencia >= cast(GETDATE()-15 as date)
			and r.Excluido = 0
			and r.StatusRota <> 'planned'
			and r.NomeMotorista <> '-' and r.NomeMotorista <> ''
			and DIFFERENCE(
				DBO.fn_remove_acentuacao(r.NomeMotorista), 
				DBO.fn_remove_acentuacao(LEFT(u.usr_nm_usuario, ISNULL(NULLIF(CHARINDEX('_', u.usr_nm_usuario) - 1, -1), LEN(u.usr_nm_usuario))))
			) <= 3
	end
	
	--MERCADO LIVRE FM
	set @QtdeUsarioDAErrados = (
									select
										count(1) qtde
									from
										tb_ml_fm_rotas r with(nolock)
										join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario
									where
										DataReferencia >= cast(GETDATE()-15 as date)
										and r.Excluido = 0
										and r.NomeMotorista <> '-' and r.NomeMotorista <> ''
										and DIFFERENCE(
											DBO.fn_remove_acentuacao(r.NomeMotorista), 
											DBO.fn_remove_acentuacao(LEFT(u.usr_nm_usuario, ISNULL(NULLIF(CHARINDEX('_', u.usr_nm_usuario) - 1, -1), LEN(u.usr_nm_usuario))))
										) <= 3
								)
								
	--colocamos por precaução para não atualizar muitas rotas esse limite
	if @QtdeUsarioDAErrados <= 100
	begin
		update
			r
		set
			r.UsuarioDA = null
		from
			tb_ml_fm_rotas r with(nolock)
			join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario
		where
			DataReferencia >= cast(GETDATE()-15 as date)
			and r.Excluido = 0
			and r.NomeMotorista <> '-' and r.NomeMotorista <> ''
			and DIFFERENCE(
				DBO.fn_remove_acentuacao(r.NomeMotorista), 
				DBO.fn_remove_acentuacao(LEFT(u.usr_nm_usuario, ISNULL(NULLIF(CHARINDEX('_', u.usr_nm_usuario) - 1, -1), LEN(u.usr_nm_usuario))))
			) <= 3
	end
	
	--MERCADO LIVRE LH
	set @QtdeUsarioDAErrados = (
										select
											count(1) qtde
										from
											tb_ml_lh_rotas r with(nolock)
											join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario
										where
											DataReferencia >= cast(GETDATE()-15 as date)
											and r.Excluido = 0
											and r.NomeMotorista <> '-' and r.NomeMotorista <> ''
											and DIFFERENCE(
												DBO.fn_remove_acentuacao(r.NomeMotorista), 
												DBO.fn_remove_acentuacao(LEFT(u.usr_nm_usuario, ISNULL(NULLIF(CHARINDEX('_', u.usr_nm_usuario) - 1, -1), LEN(u.usr_nm_usuario))))
											) <= 3
									)
									
	--colocamos por precaução para não atualizar muitas rotas esse limite
	if @QtdeUsarioDAErrados <= 100
	begin
		update
			r
		set
			r.UsuarioDA = null
		from
			tb_ml_lh_rotas r with(nolock)
			join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario
		where
			DataReferencia >= cast(GETDATE()-15 as date)
			and r.Excluido = 0
			and r.NomeMotorista <> '-' and r.NomeMotorista <> ''
			and DIFFERENCE(
				DBO.fn_remove_acentuacao(r.NomeMotorista), 
				DBO.fn_remove_acentuacao(LEFT(u.usr_nm_usuario, ISNULL(NULLIF(CHARINDEX('_', u.usr_nm_usuario) - 1, -1), LEN(u.usr_nm_usuario))))
			) <= 3
	end


	------------------------------------------------------------
	-- ALTERA USUARIO DA EM QUE ESTÁ EM USUÁRIO SEM DRIVERID MAS EXISTE OUTRO USUÁRIO ATIVO COM DRIVERID DA ROTA
	------------------------------------------------------------
	update
		r
	set
		r.UsuarioDA = null
	from
		tb_ml_rotas r with(nolock)
		join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_logistics
										and c.cli_cd_codigo_cliente <> 7
		join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario 
										and u.usr_cd_driverid is null
		join tb_usuario u2 with(nolock) on r.DriverId = u2.usr_cd_driverid 
										and c.cli_cd_codigo_cliente = u2.cli_cd_codigo_cliente
										and u2.usr_in_ativo = 1
	where
		DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.Excluido = 0
		and r.StatusRota <> 'planned'
		and r.DriverId is not null


	------------------------------------------------------------
	-- ALTERA USUARIO DA EM QUE ESTÁ EM USUÁRIO INATIVO COM DRIVERID MAS EXISTE OUTRO USUÁRIO ATIVO COM DRIVERID DA ROTA
	------------------------------------------------------------
	update
		r
	set
		r.UsuarioDA = null
	from
		tb_ml_rotas r with(nolock)
		join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_logistics
										and c.cli_cd_codigo_cliente <> 7
		join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario 
										and u.usr_cd_driverid is not null
										and u.usr_in_ativo = 0
		join tb_usuario u2 with(nolock) on r.DriverId = u2.usr_cd_driverid 
										and c.cli_cd_codigo_cliente = u2.cli_cd_codigo_cliente
										and u2.usr_in_ativo = 1
	where
		DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.Excluido = 0
		and r.StatusRota <> 'planned'
		and r.DriverId is not null
	

	------------------------------------------------------------
	-- ALTERA USUARIO DA EM QUE ESTÁ EM USUÁRIO ATIVO COM DRIVERID QUE NÃO PERTENCE A ROTA E EXISTE OUTRO USUÁRIO ATIVO COM DRIVERID DA ROTA
	------------------------------------------------------------
	update
		r
	set
		r.UsuarioDA = null
	from
		tb_ml_rotas r with(nolock)
		join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_logistics
										and c.cli_cd_codigo_cliente <> 7
		join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario 
										and u.usr_cd_driverid is not null
										and u.usr_in_ativo = 1
										and r.DriverId <> u.usr_cd_driverid
		join tb_usuario u2 with(nolock) on r.DriverId = u2.usr_cd_driverid 
										and c.cli_cd_codigo_cliente = u2.cli_cd_codigo_cliente
										and u2.usr_in_ativo = 1
	where
		DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.Excluido = 0
		and r.StatusRota <> 'planned'
		and r.DriverId is not null


	------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DO MELI - LM
	------------------------------------------------------------
	--1 Atualiza por DriverID
	update 
		r
	set 
		r.UsuarioDA = usr_cd_usuario		
	from 
		tb_ml_rotas as r with(nolock)
		join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario as u with (nolock) on u.usr_cd_driverid = r.DriverId  
											and cli.cli_cd_codigo_cliente = u.cli_cd_codigo_cliente
											and u.usr_in_ativo = 1
	where 
		1=1 --(r.DataReferencia < cast(getdate() as date) or r.StatusRota = 'close')
		and r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.excluido = 0
		and r.StatusRota <> 'planned'
		and r.UsuarioDA is null
		

	--2 Atualiza por DriverID que estiver no mesmo cpf caso não tenha encontrado na 1 opção
	--para casos em que o mesmo motorista tem mais de 1 driverId
	update 
		r
	set 
		r.UsuarioDA = usr_cd_usuario		
	from 
		tb_ml_rotas as r with(nolock)
		join tb_ml_motoristas m with(nolock) on r.DriverId = m.IdMotorista
											and r.IdTransportadora = m.IdTransportadora
		join tb_ml_motoristas m2 with(nolock) on m.Cpf = m2.Cpf
											and m.IdTransportadora = m2.IdTransportadora
											and m.IdMotorista <> m2.IdMotorista
											and m.Cpf <> ''
		join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario as u with (nolock) on u.usr_cd_driverid = m2.IdMotorista  
											and cli.cli_cd_codigo_cliente = u.cli_cd_codigo_cliente
											and u.usr_in_ativo = 1
	where 
		1=1 --(r.DataReferencia < cast(getdate() as date) or r.StatusRota = 'close')
		and r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.excluido = 0
		and r.StatusRota <> 'planned'
		and r.UsuarioDA is null
		


	--3 atualiza pelo nome
	update
		r
	set
		r.UsuarioDA = usr_cd_usuario
	from
		tb_ml_rotas as r with(nolock)
		join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario as u with (nolock) on DBO.fn_remove_acentuacao(r.NomeMotorista) = DBO.fn_remove_acentuacao(u.usr_nm_usuario)
															and cli.cli_cd_codigo_cliente = u.cli_cd_codigo_cliente
															and usr_in_ativo = 1
															and u.usr_cd_driverid is null
															and u.usr_in_motorista = 1
	where   
		r.Excluido = 0
		--and (r.DataReferencia < cast(getdate() as date) or r.StatusRota = 'close')
		and r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.StatusRota <> 'planned'
		and r.UsuarioDA is null
		and r.NomeMotorista <> '-' 
		and r.NomeMotorista <> ''


	
	--4 atualiza pelo nome que está na tb_ml_motorista
	update
		r
	set
		r.UsuarioDA = usr_cd_usuario
	from
		tb_ml_rotas as r with(nolock)
		join tb_ml_motoristas m with(nolock) on r.DriverId = m.IdMotorista and r.IdTransportadora = m.IdTransportadora
		join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario as u with (nolock) on DBO.fn_remove_acentuacao(m.Nome) = DBO.fn_remove_acentuacao(u.usr_nm_usuario)
															and cli.cli_cd_codigo_cliente = u.cli_cd_codigo_cliente
															and usr_in_ativo = 1
															and u.usr_cd_driverid is null
															and u.usr_in_motorista = 1 
	where   
		r.Excluido = 0
		--and (r.DataReferencia < cast(getdate() as date) or r.StatusRota = 'close')
		and r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.StatusRota <> 'planned'
		and r.UsuarioDA is null
		and r.NomeMotorista <> '-' 
		and r.NomeMotorista <> ''


	--5 atualiza pelo nome sem olhar driver id somente para as transportadoras que não estiverem na V3
	update
		r
	set
		r.UsuarioDA = usr_cd_usuario
	from
		tb_ml_rotas as r with(nolock)
		join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario as u with (nolock) on DBO.fn_remove_acentuacao(r.NomeMotorista) = DBO.fn_remove_acentuacao(LEFT(u.usr_nm_usuario, 
																			ISNULL(NULLIF(CHARINDEX('_', u.usr_nm_usuario) - 1, -1), LEN(u.usr_nm_usuario))))
															and cli.cli_cd_codigo_cliente = u.cli_cd_codigo_cliente
															and u.usr_in_ativo = 1
															and u.cli_cd_codigo_cliente not in (select 
																									prm_cod_cliente
																								from
																									tb_parametros with(nolock)
																								where
																									prm_cod_cliente is not null
																									and prm_nm_parametro = 'Habilitar Homônimos Usuários'
																									and prm_in_ativo = 1
																									and prm_in_excluido = 0
																									and prm_ds_valor = 'true'
																								)
	where   
		r.Excluido = 0
		--and (r.DataReferencia < cast(getdate() as date) or r.StatusRota = 'close')
		and r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.StatusRota <> 'planned'
		and r.UsuarioDA is null
		and r.NomeMotorista <> '-' 
		and r.NomeMotorista <> ''


	--6 atualiza pelo nome que está na tb_ml_motorista sem olhar driver id somente para as transportadoras que não estiverem na V3
	update
		r
	set
		r.UsuarioDA = usr_cd_usuario
	from
		tb_ml_rotas as r with(nolock)
		join tb_ml_motoristas m with(nolock) on r.DriverId = m.IdMotorista and r.IdTransportadora = m.IdTransportadora
		join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario as u with (nolock) on DBO.fn_remove_acentuacao(m.Nome) = DBO.fn_remove_acentuacao(LEFT(u.usr_nm_usuario, 
																			ISNULL(NULLIF(CHARINDEX('_', u.usr_nm_usuario) - 1, -1), LEN(u.usr_nm_usuario))))
															and cli.cli_cd_codigo_cliente = u.cli_cd_codigo_cliente
															and u.usr_in_ativo = 1
															and u.cli_cd_codigo_cliente not in (select 
																									prm_cod_cliente
																								from
																									tb_parametros with(nolock)
																								where
																									prm_cod_cliente is not null
																									and prm_nm_parametro = 'Habilitar Homônimos Usuários'
																									and prm_in_ativo = 1
																									and prm_in_excluido = 0
																									and prm_ds_valor = 'true'
																								)										
	where   
		r.Excluido = 0
		--and (r.DataReferencia < cast(getdate() as date) or r.StatusRota = 'close')
		and r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and r.StatusRota <> 'planned'
		and r.UsuarioDA is null
		and r.NomeMotorista <> '-' 
		and r.NomeMotorista <> ''


	------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DO MELI - FM
	------------------------------------------------------------
	update 
		r
	set 
		r.UsuarioDA = usr_cd_usuario
	from 
		tb_ml_fm_rotas as r with(nolock)
		join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario AS codusuario WITH (NOLOCK) ON DBO.fn_remove_acentuacao(r.NomeMotoristA) = DBO.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
															ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))
													and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente
	where 
		r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date) 
		and UsuarioDA is null
		and excluido = 0
		and usr_in_ativo = 1


	------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DA SHOPEE
	------------------------------------------------------------
	update 
		r
	set 
		r.UsuarioIrisys = usr_cd_usuario
	from 
		tb_spe_rotas_v5 as r with(nolock)
		join tb_clientes as cli with(nolock) on cli.cli_id_shopee = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario AS codusuario WITH (NOLOCK) ON DBO.fn_remove_acentuacao(r.motorista) =  DBO.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
															ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))
													and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente
	where 
		r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date) 
		and UsuarioIrisys is null
		and excluido = 0
		and usr_in_ativo = 1


	------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DO MELI - MO
	------------------------------------------------------------
	update 
		r
	set 
		r.UsuarioDA = usr_cd_usuario
	from 
		tb_ml_mo_rotas as r with(nolock)
		join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
											and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario AS codusuario WITH (NOLOCK) ON DBO.fn_remove_acentuacao(r.NomeMotoristA) = DBO.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
																ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))
											and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente
	where 
		r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and UsuarioDA is null
		and excluido = 0
		and usr_in_ativo = 1


	------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DO MELI - LH
	------------------------------------------------------------
	update 
		r
	set 
		r.UsuarioDA = usr_cd_usuario
	from 
		tb_ml_lh_rotas r with(nolock)
		join tb_clientes cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
										and cli.cli_cd_codigo_cliente <> 7
		join tb_usuario codusuario with (nolock) on dbo.fn_remove_acentuacao(r.NomeMotorista) = dbo.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
																									ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))
														and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente
	where 
		r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - @MesesRetroativo, 0) as date)
		and excluido = 0
		and usr_in_ativo = 1
		and r.UsuarioDA is null


	
	------------------------------------------------------------
	-- ATUALIZA NÍVEL MOTORISTAS
	------------------------------------------------------------
	exec UpsAtualizaNivelMotoristas ;


	------------------------------------------------------------
	-- ATUALIZA ÚSUÁRIOS INATIVOS
	------------------------------------------------------------
	exec uspAtualizaUsuarioInativo;




end
GO
