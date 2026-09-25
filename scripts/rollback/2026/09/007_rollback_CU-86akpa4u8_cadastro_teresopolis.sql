/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpa4u8
  Autor        : Devin
  Data         : 2026-09-25
  Descrição    : Reverte o cadastro de locais de Teresopolis/RJ do cliente Hawk
                 Transportes (66):
                 1) remove os 78 vinculos em tb_fin_definie_cidade_distrito
                 2) remove APENAS os 45 nomes criados pelo forward em
                    tb_fin_distritos_cadastrados (lista fixa abaixo) e somente
                    se nao estiverem referenciados - os 33 nomes pre-existentes
                    nunca sao tocados.
  Forward ref  : scripts/forward/2026/09/007_forward_CU-86akpa4u8_cadastro_teresopolis.sql
  Objetos      : dbo.tb_fin_definie_cidade_distrito (DELETE),
                 dbo.tb_fin_distritos_cadastrados (DELETE)
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    --==========================================================================
    -- 1. STAGING: mesmas 78 linhas do forward + 45 nomes criados pelo forward
    --==========================================================================
    DECLARE @stage TABLE (
        base_sigla    nvarchar(100) NOT NULL,
        local_nome    varchar(50)   NOT NULL,
        regiao_label  varchar(50)   NOT NULL
    );

    INSERT INTO @stage (base_sigla, local_nome, regiao_label) VALUES
        (N'SRJ5', N'TERESÓPOLIS', N'Distrito'),
        (N'SRJ5', N'Agriões', N'Bairro'),
        (N'SRJ5', N'Albuquerque', N'Bairro'),
        (N'SRJ5', N'Alto', N'Bairro'),
        (N'SRJ5', N'Araras', N'Bairro'),
        (N'SRJ5', N'Bairro dos Artistas', N'Bairro'),
        (N'SRJ5', N'Barra do Imbuí', N'Bairro'),
        (N'SRJ5', N'Barroso', N'Bairro'),
        (N'SRJ5', N'Caleme', N'Bairro'),
        (N'SRJ5', N'Campo Grande', N'Bairro'),
        (N'SRJ5', N'Carlos Guinle', N'Bairro'),
        (N'SRJ5', N'Cascata do Imbuí', N'Bairro'),
        (N'SRJ5', N'Cascata dos Amores', N'Bairro'),
        (N'SRJ5', N'Cascata Guarani', N'Bairro'),
        (N'SRJ5', N'Caxangá', N'Bairro'),
        (N'SRJ5', N'Corta Vento', N'Bairro'),
        (N'SRJ5', N'Ermitage', N'Bairro'),
        (N'SRJ5', N'Espanhol', N'Bairro'),
        (N'SRJ5', N'Fátima', N'Bairro'),
        (N'SRJ5', N'Fazendinha', N'Bairro'),
        (N'SRJ5', N'Fonte Santa', N'Bairro'),
        (N'SRJ5', N'Golfe', N'Bairro'),
        (N'SRJ5', N'Granja Florestal', N'Bairro'),
        (N'SRJ5', N'Iucas', N'Bairro'),
        (N'SRJ5', N'Jardim Cascata', N'Bairro'),
        (N'SRJ5', N'Jardim Europa', N'Bairro'),
        (N'SRJ5', N'Jardim Meudon', N'Bairro'),
        (N'SRJ5', N'Jardim Salaco', N'Bairro'),
        (N'SRJ5', N'Meudon', N'Bairro'),
        (N'SRJ5', N'Morro dos Pinheiros', N'Bairro'),
        (N'SRJ5', N'Nossa Senhora de Fátima', N'Bairro'),
        (N'SRJ5', N'Paineiras', N'Bairro'),
        (N'SRJ5', N'Parque do Imbuí', N'Bairro'),
        (N'SRJ5', N'Parque do Ingá', N'Bairro'),
        (N'SRJ5', N'Parque São Luiz', N'Bairro'),
        (N'SRJ5', N'Pimenteiras', N'Bairro'),
        (N'SRJ5', N'Posse', N'Bairro'),
        (N'SRJ5', N'Prata', N'Bairro'),
        (N'SRJ5', N'Quebra Frascos', N'Bairro'),
        (N'SRJ5', N'Quinta Lebrão', N'Bairro'),
        (N'SRJ5', N'Santa Cecília', N'Bairro'),
        (N'SRJ5', N'São Pedro', N'Bairro'),
        (N'SRJ5', N'Taumaturgo', N'Bairro'),
        (N'SRJ5', N'Tijuca', N'Bairro'),
        (N'SRJ5', N'Vale do Paraíso', N'Bairro'),
        (N'SRJ5', N'Várzea', N'Bairro'),
        (N'SRJ5', N'Vila Muqui', N'Bairro'),
        (N'SRJ5', N'VALE DE BONSUCESSO', N'Distrito'),
        (N'SRJ5', N'Campanha', N'Bairro'),
        (N'SRJ5', N'Corrêgo Sujo', N'Bairro'),
        (N'SRJ5', N'Vargem Grande', N'Bairro'),
        (N'SRJ5', N'Venda Nova', N'Bairro'),
        (N'SRJ5', N'Vista Alegre', N'Bairro'),
        (N'SRJ5', N'Frades', N'Bairro'),
        (N'SRJ5', N'Bonsucesso', N'Bairro'),
        (N'SRJ5', N'Motas', N'Bairro'),
        (N'SRJ5', N'Sebastiana', N'Bairro'),
        (N'SRJ5', N'Santa Rosa', N'Bairro'),
        (N'SRJ5', N'Vieira', N'Bairro'),
        (N'SRJ5', N'Morro Agudo', N'Bairro'),
        (N'SRJ5', N'Boa Vista', N'Bairro'),
        (N'SRJ5', N'VALE DO PARQUEQUER', N'Distrito'),
        (N'SRJ6', N'Três Córregos', N'Bairro'),
        (N'SRJ7', N'Pessegueiros', N'Bairro'),
        (N'SRJ5', N'Santa Rita', N'Bairro'),
        (N'SRJ5', N'Campo Limpo', N'Bairro'),
        (N'SRJ5', N'Colonia Alpina', N'Bairro'),
        (N'SRJ5', N'Granja Mafra', N'Bairro'),
        (N'SRJ5', N'Cruzeiro', N'Bairro'),
        (N'SRJ5', N'Andradas', N'Bairro'),
        (N'SRJ5', N'Providência', N'Bairro'),
        (N'SRJ5', N'Ponte Nova', N'Bairro'),
        (N'SRJ5', N'Quebra Coco', N'Bairro'),
        (N'SRJ5', N'Água Quente', N'Bairro'),
        (N'SRJ5', N'Volta do Pião', N'Bairro'),
        (N'SRJ5', N'Serra do Capim', N'Bairro'),
        (N'SRJ5', N'Prates', N'Bairro'),
        (N'SRJ5', N'Retiro da Serra', N'Bairro');

    DECLARE @distritos_novos TABLE (nome varchar(50) NOT NULL PRIMARY KEY);
    INSERT INTO @distritos_novos (nome) VALUES
        (N'Agriões'),
        (N'Alto'),
        (N'Bairro dos Artistas'),
        (N'Barra do Imbuí'),
        (N'Caleme'),
        (N'Carlos Guinle'),
        (N'Cascata Guarani'),
        (N'Cascata do Imbuí'),
        (N'Cascata dos Amores'),
        (N'Caxangá'),
        (N'Colonia Alpina'),
        (N'Corrêgo Sujo'),
        (N'Corta Vento'),
        (N'Ermitage'),
        (N'Espanhol'),
        (N'Fonte Santa'),
        (N'Frades'),
        (N'Golfe'),
        (N'Granja Florestal'),
        (N'Granja Mafra'),
        (N'Iucas'),
        (N'Jardim Cascata'),
        (N'Jardim Europa'),
        (N'Jardim Meudon'),
        (N'Jardim Salaco'),
        (N'Meudon'),
        (N'Morro dos Pinheiros'),
        (N'Motas'),
        (N'Parque São Luiz'),
        (N'Parque do Imbuí'),
        (N'Parque do Ingá'),
        (N'Pessegueiros'),
        (N'Prates'),
        (N'Quebra Coco'),
        (N'Quebra Frascos'),
        (N'Quinta Lebrão'),
        (N'Retiro da Serra'),
        (N'Sebastiana'),
        (N'Serra do Capim'),
        (N'Taumaturgo'),
        (N'Tijuca'),
        (N'VALE DO PARQUEQUER'),
        (N'Vieira'),
        (N'Vila Muqui'),
        (N'Volta do Pião');

    --==========================================================================
    -- 2. DELETE vinculos (somente combinacoes exatas da staging, cliente 66)
    --==========================================================================
    DECLARE @cd_cliente int = 66;
    DECLARE @cd_cidade  int;

    SELECT @cd_cidade = cid_cd_cidade
    FROM dbo.tb_codigos_cidades
    WHERE cid_ds_cidade = N'Teresópolis'
      AND cid_cd_estado = 33;

    DELETE f
    FROM dbo.tb_fin_definie_cidade_distrito f
    JOIN dbo.tb_bases b
        ON b.bss_cd_base = f.fcd_cd_Base
       AND b.bss_cod_cliente = @cd_cliente
    JOIN dbo.tb_fin_distritos_cadastrados d
        ON d.IdDistrito = f.fcd_cd_distrito
    JOIN dbo.tb_lista l
        ON l.lst_cd_lista = f.fcd_cd_regiao
       AND l.lst_nm_lista = 'Regiao de entrega'
    JOIN @stage s
        ON s.base_sigla   = b.bss_ds_sigla
       AND s.local_nome   = d.NomeDistrito
       AND s.regiao_label = l.lst_ds_label
    WHERE f.fcd_cd_cliente = @cd_cliente
      AND f.fcd_cd_cidade  = @cd_cidade;

    DECLARE @vinculos_removidos int = @@ROWCOUNT;

    --==========================================================================
    -- 3. DELETE distritos criados pelo forward (somente se sem referencia)
    --==========================================================================
    DELETE d
    FROM dbo.tb_fin_distritos_cadastrados d
    JOIN @distritos_novos n
        ON n.nome = d.NomeDistrito
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tb_fin_definie_cidade_distrito f
        WHERE f.fcd_cd_distrito = d.IdDistrito
    )
    AND NOT EXISTS (
        SELECT 1
        FROM dbo.tb_fin_Cidades_DePara dp
        WHERE dp.cid_cd_base_ibge = d.IdDistrito
    );

    DECLARE @distritos_removidos int = @@ROWCOUNT;

    --==========================================================================
    -- 4. POS-CHECKS
    --==========================================================================
    DECLARE @restantes int;
    SELECT @restantes = COUNT(*)
    FROM dbo.tb_fin_definie_cidade_distrito
    WHERE fcd_cd_cliente = @cd_cliente;

    IF @restantes <> 0
        THROW 50008, 'Pos-check falhou: ainda existem vinculos do cliente 66.', 1;

    PRINT 'Vinculos removidos de tb_fin_definie_cidade_distrito: ' + CAST(@vinculos_removidos AS varchar);
    PRINT 'Distritos removidos de tb_fin_distritos_cadastrados: ' + CAST(@distritos_removidos AS varchar);

    COMMIT TRAN;
    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
