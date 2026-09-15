-- ============================================================
-- BASELINE: dbo.vw_motoristas_transportadoras
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_motoristas_transportadoras]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_motoristas_transportadoras]
as

SELECT 
    MAX(IdRota) AS Id,
    'ML' AS MarketPlace,
    NomeMotorista,
    cli.cli_cd_codigo_cliente AS IdTransportadora,
    MAX(users.usr_matricula) AS Matricula
FROM tb_ml_rotas AS rotas WITH (NOLOCK)
INNER JOIN tb_clientes AS cli 
    ON rotas.IdTransportadora = cli.cli_id_logistics
INNER JOIN tb_usuario AS users 
    ON users.usr_cd_usuario = rotas.UsuarioDA 
WHERE rotas.Excluido = 0
GROUP BY 
    NomeMotorista,
    cli.cli_cd_codigo_cliente

UNION ALL

SELECT 
    MAX(IdRota) AS Id,
    'LH' AS MarketPlace,
    NomeMotorista,
    cli.cli_cd_codigo_cliente AS IdTransportadora,
    MAX(users.usr_matricula) AS Matricula
FROM tb_ml_lh_rotas AS rotas WITH (NOLOCK)
INNER JOIN tb_clientes AS cli 
    ON rotas.IdTransportadora = cli.cli_id_logistics
INNER JOIN tb_usuario AS users 
    ON users.usr_cd_usuario = rotas.UsuarioDA 
WHERE rotas.Excluido = 0
GROUP BY 
    NomeMotorista,
    cli.cli_cd_codigo_cliente

UNION ALL

SELECT 
    usr_cd_usuario AS Id,
    'ML' AS MarketPlace,
    usr_nm_usuario AS NomeMotorista,
    cli.cli_cd_codigo_cliente AS IdTransportadora,
    users.usr_matricula AS Matricula
FROM tb_usuario AS users
INNER JOIN tb_clientes AS cli 
    ON users.cli_cd_codigo_cliente = cli.cli_cd_codigo_cliente
LEFT JOIN (
    SELECT DISTINCT NomeMotorista, IdTransportadora
    FROM tb_ml_rotas
    WHERE Excluido = 0
) AS rotas
    ON cli.cli_id_logistics = rotas.IdTransportadora
    AND rotas.NomeMotorista = users.usr_nm_usuario
WHERE rotas.IdTransportadora IS NULL
    AND cli_in_ativo = 1
    AND usr_in_motorista = 1

UNION ALL

SELECT 
    usr_cd_usuario AS Id,
    'LH' AS MarketPlace,
    usr_nm_usuario AS NomeMotorista,
    cli.cli_cd_codigo_cliente AS IdTransportadora,
    users.usr_matricula AS Matricula
FROM tb_usuario AS users
INNER JOIN tb_clientes AS cli 
    ON users.cli_cd_codigo_cliente = cli.cli_cd_codigo_cliente
LEFT JOIN (
    SELECT DISTINCT NomeMotorista, IdTransportadora
    FROM tb_ml_lh_rotas
    WHERE Excluido = 0
) AS rotas
    ON cli.cli_id_logistics = rotas.IdTransportadora
    AND rotas.NomeMotorista = users.usr_nm_usuario
WHERE rotas.IdTransportadora IS NULL
    AND cli_in_ativo = 1
    AND usr_in_motorista = 1;
GO
