-- ============================================================
-- BASELINE: dbo.vw_relatorio_sinistros
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_relatorio_sinistros]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_relatorio_sinistros] AS
SELECT 
    s.sin_cd_cliente_transportadora AS TenantId,
    s.Sin_cd_sinistro,
    s.sin_ds_matricula,
    s.sin_cd_cod_driver AS Cd_Usuario,
    u.usr_nm_usuario,
    CASE 
       WHEN s.sin_in_possui_ajudante = 0 THEN 'Não'
       WHEN s.sin_in_possui_ajudante = 1 THEN 'Sim'
       ELSE 'Erro' END AS Possui_Ajudante,
    s.Sin_cd_transportadora AS Cd_MarketPlace,
    CAST(s.sin_dt_data AS date) AS Data_Sinistro,
    b.bss_ds_nome,
    s.sin_route AS Idrota,
    s.sin_dt_hora_sinistro AS Hora_Sinistro,
    v.vei_ds_tipo,
    s.sin_ds_placa AS Placa,
    CASE
        WHEN s.sin_in_elemento_assumiu_direcao_veiculo = 1 THEN 'Sim'
        WHEN s.sin_in_elemento_assumiu_direcao_veiculo = 0 THEN 'Não'
        ELSE 'Erro' END AS Elemento_Assumiu,
    COALESCE(l_fase.lst_ds_valor, CAST(s.sin_cd_fase_transporte AS varchar(50))) AS sin_cd_fase_transporte,
    s.sin_qt_pacotes,
    s.sin_qt_pacotes_entregues,
    s.sin_qt_pacotes_insucesso,
    s.sin_qt_sinistrado,
    s.sin_qt_recuperada,
    s.sin_ds_numero_solicitacao_monitoramento_veiculo,
    s.sin_in_ativo,
    COALESCE(l_status.lst_ds_valor, CAST(s.sin_status AS varchar(50))) AS sin_status,
    s.sin_ds_cep,
    s.sin_ds_rua,
    s.sin_ds_numero,
    s.sin_ds_complemento,
    s.sin_ds_bairro,
    s.sin_ds_cidade,
    s.sin_ds_estado,
    COALESCE(l_nat.lst_ds_valor, CAST(s.sin_cd_natureza_sinistro AS varchar(50))) AS sin_cd_natureza_sinistro,
    COALESCE(l_perimeter.lst_ds_valor, CAST(s.sin_perimeter AS varchar(50))) AS sin_perimeter,
    CASE
        WHEN s.sin_in_descontar_motorista = 0 THEN 'Não'
        WHEN s.sin_in_descontar_motorista = 1 THEN 'Sim'
        ELSE 'Erro' END AS Descontar_Motorista,
    CASE
        WHEN s.sin_in_descontar_success_delivery = 1 THEN 'Sim'
        WHEN s.sin_in_descontar_success_delivery = 0 THEN 'Não'
        ELSE 'Erro' END AS Descontar_Sucess_Delivery,
    s.sin_vl_valor_total_embarcado,
    s.sin_vl_valor_total_prejuizo,
    s.sin_vl_valor_total_recuperado,
    s.sin_ds_numero_processo_seguradora,
    COALESCE(l_seguradora.lst_ds_valor, CAST(s.sin_ds_seguradora AS varchar(50))) AS sin_ds_seguradora,
    s.sin_ds_status_seguro AS Status_Seguro,
    s.sin_ds_status_motorista,
    s.sin_ds_bo_preliminar,
    s.sin_ds_link_bo_preliminar,
    s.sin_ds_bo,
    s.sin_ds_link_bo
FROM dbo.tb_sin_sinistro s
LEFT JOIN dbo.tb_usuario u
    ON u.usr_cd_usuario = s.sin_cd_cod_driver
LEFT JOIN dbo.tb_bases b
    ON b.bss_cd_base = s.sin_cd_base
LEFT JOIN dbo.tb_veiculos v
    ON s.sin_ds_placa = v.vei_ds_placa
LEFT JOIN dbo.tb_lista l_fase
    ON l_fase.lst_nm_lista = 'fase_transporte'
   AND TRY_CONVERT(int, l_fase.lst_ds_chave) = s.sin_cd_fase_transporte
LEFT JOIN dbo.tb_lista l_status
    ON l_status.lst_nm_lista = 'status_sinistro'
   AND TRY_CONVERT(int, l_status.lst_ds_chave) = s.sin_status
LEFT JOIN dbo.tb_lista l_nat
    ON l_nat.lst_nm_lista = 'natureza_sinistro'
   AND TRY_CONVERT(int, l_nat.lst_ds_chave) = s.sin_cd_natureza_sinistro
LEFT JOIN dbo.tb_lista l_perimeter
    ON l_perimeter.lst_nm_lista IN ('perimeter', 'sin_perimeter')
   AND TRY_CONVERT(int, l_perimeter.lst_ds_chave) = s.sin_perimeter
LEFT JOIN dbo.tb_lista l_seguradora
    ON l_seguradora.lst_nm_lista = 'Nome seguradora'
   AND TRY_CONVERT(int, l_seguradora.lst_ds_chave) = s.sin_ds_seguradora;
GO
