-- ============================================================
-- BASELINE: dbo.uspAtualizaUsuarioInativo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[uspAtualizaUsuarioInativo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[uspAtualizaUsuarioInativo]
as
begin

	------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DO MELI - LM
	------------------------------------------------------------
	drop table if exists #ultima_data
	select
		DriverId
		,IdTransportadora
		,max(DataReferencia) DataReferencia
		into #ultima_data
	from
		tb_ml_rotas r with(nolock)
	where
		DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - 1, 0) as date)
		and Excluido = 0
		and StatusRota <> 'planned'
		and NomeMotorista <> '-' 
		and NomeMotorista <> ''
		and NomeMotorista is not null
		and UsuarioDA is not null
	group by
		DriverId
		,IdTransportadora


	drop table if exists #ultimo_usuarioDA
	select
		r.DriverId
		,r.IdTransportadora
		,max(r.UsuarioDA) UsuarioDA
		into #ultimo_usuarioDA
	from
		tb_ml_rotas r with(nolock)
		join #ultima_data d on r.DriverId = d.DriverId
							and r.IdTransportadora = d.IdTransportadora
							and r.DataReferencia = d.DataReferencia
	where
		r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - 1, 0) as date)
		and r.Excluido = 0
		and r.StatusRota <> 'planned'
		and r.NomeMotorista <> '-' 
		and r.NomeMotorista <> ''
		and r.NomeMotorista is not null
		and r.UsuarioDA is not null
	group by 
		r.DriverId
		,r.IdTransportadora


	update
		r
	set
		r.UsuarioDA = u.UsuarioDA
	from
		tb_ml_rotas r with(nolock)
		join #ultimo_usuarioDA u on r.DriverId = u.DriverId
								and r.IdTransportadora = u.IdTransportadora
								and r.UsuarioDA <> u.UsuarioDA
	where
		r.DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - 1, 0) as date)
		and r.Excluido = 0
		and r.StatusRota <> 'planned'
		and r.NomeMotorista <> '-' 
		and r.NomeMotorista <> ''
		and r.NomeMotorista is not null
		and r.UsuarioDA is not null


    ------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DO MELI - FM
	------------------------------------------------------------
	
    -- CTE para obter os motoristas com a data mais recente
    ;WITH MotoristasComDataMaxima AS (
        SELECT 
            NomeMotorista,
            IdTransportadora,
            MAX(DataReferencia) AS DataReferencia
        FROM 
            tb_ml_fm_rotas WITH (NOLOCK)
        WHERE 
            DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - 1, 0) as date)
            AND usuarioda IS NOT NULL
        GROUP BY 
            NomeMotorista, 
            IdTransportadora
    ),
    -- CTE para obter os usuários correspondentes aos motoristas com data máxima
    MotoristasComUsuario AS (
        SELECT 
            r.usuarioda,
            r.NomeMotorista,
            r.IdTransportadora
        FROM 
            tb_ml_fm_rotas r WITH (NOLOCK)
            INNER JOIN MotoristasComDataMaxima m ON r.NomeMotorista = m.NomeMotorista
                                                    AND r.IdTransportadora = m.IdTransportadora
                                                    AND r.DataReferencia = m.DataReferencia
    )
    -- Atualização final somente se o valor for diferente
    UPDATE 
        r
    SET 
        r.usuarioda = m.usuarioda
    FROM 
        tb_ml_fm_rotas r
        INNER JOIN MotoristasComUsuario m ON r.NomeMotorista = m.NomeMotorista
                                            AND r.IdTransportadora = m.IdTransportadora
    WHERE 
        r.usuarioda IS NULL OR r.usuarioda <> m.usuarioda;


    ------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DO MELI - MO
	------------------------------------------------------------
    WITH MotoristasComDataMaxima AS (
        SELECT 
            NomeMotorista,
            IdTransportadora,
            MAX(DataReferencia) AS DataReferencia
        FROM 
            tb_ml_MO_rotas WITH (NOLOCK)
        WHERE 
            DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - 1, 0) as date)
            AND usuarioda IS NOT NULL
        GROUP BY 
            NomeMotorista, IdTransportadora
    ),
    -- CTE para obter os usuários correspondentes aos motoristas com data máxima
    MotoristasComUsuario AS (
        SELECT 
            r.usuarioda,
            r.NomeMotorista,
            r.IdTransportadora
        FROM 
            tb_ml_MO_rotas r WITH (NOLOCK)
            INNER JOIN MotoristasComDataMaxima m ON r.NomeMotorista = m.NomeMotorista
                                                AND r.IdTransportadora = m.IdTransportadora
                                                AND r.DataReferencia = m.DataReferencia
    )
    -- Atualização final somente se o valor for diferente
    UPDATE 
        r
    SET 
        r.usuarioda = m.usuarioda
    FROM 
        tb_ml_MO_rotas r
        INNER JOIN MotoristasComUsuario m ON r.NomeMotorista = m.NomeMotorista
                                            AND r.IdTransportadora = m.IdTransportadora
    WHERE 
        r.usuarioda <> m.usuarioda;


    ------------------------------------------------------------
	-- ATUALIZA USUARIODA DE ROTAS DA SHOPEE
	------------------------------------------------------------
    WITH MotoristasComDataMaxima AS (
        SELECT 
            Motorista,
            IdTransportadora,
            MAX(DataReferencia) AS DataReferencia
        FROM 
            tb_spe_rotas_v5 WITH (NOLOCK)
        WHERE 
            DataReferencia >= cast(dateadd(month, datediff(month, 0, getdate()) - 1, 0) as date)
            AND usuarioirisys IS NOT NULL
        GROUP BY 
            Motorista, 
            IdTransportadora
    ),
    -- CTE para obter os usuários correspondentes aos motoristas com data máxima
    MotoristasComUsuario AS (
        SELECT 
            r.usuarioirisys,
            r.Motorista,
            r.IdTransportadora
        FROM 
            tb_spe_rotas_v5 r WITH (NOLOCK)
            INNER JOIN MotoristasComDataMaxima m ON r.Motorista = m.Motorista
                                                AND r.IdTransportadora = m.IdTransportadora
                                                AND r.DataReferencia = m.DataReferencia
    )
    -- Atualização final somente se o valor for diferente
    UPDATE 
        r
    SET 
        r.usuarioirisys = m.usuarioirisys
    FROM 
        tb_spe_rotas_v5 r
        INNER JOIN MotoristasComUsuario m ON r.Motorista = m.Motorista
                                        AND r.IdTransportadora = m.IdTransportadora
    WHERE 
        r.usuarioirisys <> m.usuarioirisys;


END
GO
