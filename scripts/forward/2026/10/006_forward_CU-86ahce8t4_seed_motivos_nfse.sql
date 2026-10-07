/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahce8t4
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Popula o catálogo global de motivos de reprovação NFSe:
                 7 motivos de regra + 4 motivos de regra novos (paridade QAS,
                 ainda não referenciados pela view de PROD) + 14 motivos de
                 erro de integração (match por mtr_ds_descricao = texto exato
                 do enf_ds_resultado). Idempotente: NOT EXISTS por chave
                 (regras) / por descrição (erros).
  Rollback     : scripts/rollback/2026/10/006_rollback_CU-86ahce8t4_seed_motivos_nfse.sql
  Objetos      : dbo.tb_pag_nfse_motivo_reprovacao (dados)
  Dependências : 005_forward (schema definitivo das tabelas)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    -- 1) Ativa motivos existentes (no-op se a tabela foi recriada pelo 005)
    UPDATE dbo.tb_pag_nfse_motivo_reprovacao
    SET mtr_in_ativo = 1
    WHERE mtr_in_ativo IS NULL;

    -- 1b) 7 motivos base de validação
    DECLARE @base TABLE (chave varchar(50), descricao varchar(150), mensagem varchar(255));
    INSERT INTO @base VALUES
     ('VALOR_TOLERANCIA',       'Valor fora da tolerancia',       'Recusado: valor do espelho está fora da tolerância permitida.'),
     ('DATA_EMISSAO',           'Data de emissao da NFSe',        'Recusado: data de emissão da NFSe não corresponde ao período de pagamento.'),
     ('CNPJ_TOMADOR',           'CNPJ do tomador',                'Recusado: CNPJ do tomador da NFSe não confere com o cadastro da empresa.'),
     ('CEP',                    'CEP do tomador',                 'Recusado: CEP informado na NFSe não corresponde ao cadastro da empresa.'),
     ('CNPJ_EMITENTE_FORMATO',  'CNPJ do emitente (formato)',     'Recusado: CNPJ do emitente da NFSe inválido ou em formato incorreto.'),
     ('CNPJ_EMITENTE_CADASTRO', 'CNPJ do emitente (cadastro)',    'Recusado: CNPJ do emitente da NFSe é divergente do cadastro do motorista'),
     ('COD_SERVICO',            'Codigo de servico',              'Recusado: código de serviço da NFSe não está na lista permitida.');

    INSERT INTO dbo.tb_pag_nfse_motivo_reprovacao (mtr_ds_chave, mtr_ds_descricao, mtr_ds_mensagem_padrao, mtr_in_ativo)
    SELECT b.chave, b.descricao, b.mensagem, 1
    FROM @base b
    WHERE NOT EXISTS (SELECT 1 FROM dbo.tb_pag_nfse_motivo_reprovacao t WHERE t.mtr_ds_chave = b.chave);

    -- 2) Motivos de regra novos (paridade QAS — view de PROD ainda não os usa)
    IF NOT EXISTS (SELECT 1 FROM dbo.tb_pag_nfse_motivo_reprovacao WHERE mtr_ds_chave = 'DATA_COMPETENCIA_NULA')
        INSERT INTO dbo.tb_pag_nfse_motivo_reprovacao (mtr_ds_chave, mtr_ds_descricao, mtr_ds_mensagem_padrao, mtr_in_ativo)
        VALUES ('DATA_COMPETENCIA_NULA', 'Data de competencia nao informada', 'Recusado: data de competência não informada na NFSe.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.tb_pag_nfse_motivo_reprovacao WHERE mtr_ds_chave = 'DATA_COMPETENCIA')
        INSERT INTO dbo.tb_pag_nfse_motivo_reprovacao (mtr_ds_chave, mtr_ds_descricao, mtr_ds_mensagem_padrao, mtr_in_ativo)
        VALUES ('DATA_COMPETENCIA', 'Data de competencia fora do periodo', 'Recusado: data de competência da NFSe não corresponde ao período de pagamento.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.tb_pag_nfse_motivo_reprovacao WHERE mtr_ds_chave = 'SEM_TOMADOR')
        INSERT INTO dbo.tb_pag_nfse_motivo_reprovacao (mtr_ds_chave, mtr_ds_descricao, mtr_ds_mensagem_padrao, mtr_in_ativo)
        VALUES ('SEM_TOMADOR', 'NFSe sem tomador destacado', 'Recusado: NFSe não possui tomador destacado.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.tb_pag_nfse_motivo_reprovacao WHERE mtr_ds_chave = 'EMISSAO_TERCEIRO')
        INSERT INTO dbo.tb_pag_nfse_motivo_reprovacao (mtr_ds_chave, mtr_ds_descricao, mtr_ds_mensagem_padrao, mtr_in_ativo)
        VALUES ('EMISSAO_TERCEIRO', 'NFSe emitida em nome de terceiro', 'Recusado: NFSe emitida em nome de terceiro.', 1);

    -- 3) Motivos de erro de integração (match por descrição = texto exato do enf_ds_resultado)
    DECLARE @motivos TABLE (
        chave     varchar(50)  NOT NULL,
        descricao varchar(150) NOT NULL,
        mensagem  varchar(255) NOT NULL
    );

    INSERT INTO @motivos (chave, descricao, mensagem) VALUES
     ('ERRO_GENERICO',        'An error has occurred.',                                                                          'An error has occurred.'),
     ('ARQ_CORROMPIDO',       'Arquivo cororompido',                                                                             'Arquivo cororompido'),
     ('XML_PROCESSADO',       'Arquivo XML - Processado com sucesso',                                                            'Arquivo XML - Processado com sucesso'),
     ('DOC_FORA_PADRAO',      'Documento fora do padrão do governo.',                                                            'Documento fora do padrão do governo.'),
     ('ERRO_ANALISE',         'Erro ao analisar a NFSe',                                                                         'Erro ao analisar a NFSe'),
     ('ERRO_BAIXAR_ARQUIVO',  'Erro ao baixar arquivo',                                                                          'Erro ao baixar arquivo'),
     ('ERRO_BAIXAR_PDF',      'Erro ao baixar PDF',                                                                              'Erro ao baixar PDF'),
     ('ERRO_API',             'Erro ao buscar a NFSe na API',                                                                    'Erro ao buscar a NFSe na API'),
     ('CHAVE_NAO_ENCONTRADA', 'Não foi possível buscar a chave da NFSe do arquivo PDF',                                          'Não foi possível buscar a chave da NFSe do arquivo PDF'),
     ('XML_NAO_ENCONTRADO',   'Não foi possível buscar o XML da nota fiscal com a chave informada',                              'Não foi possível buscar o XML da nota fiscal com a chave informada'),
     ('PDF_IMAGEM',           'O arquivo PDF é uma imagem. Não é possível extrair a chave da NFSe automaticamente',              'O arquivo PDF é uma imagem. Não é possível extrair a chave da NFSe automaticamente'),
     ('PDF_SEM_CONTEUDO',     'O arquivo PDF está sem conteúdo. Não é possível extrair a chave da NFSe automaticamente',         'O arquivo PDF está sem conteúdo. Não é possível extrair a chave da NFSe automaticamente'),
     ('PDF_INVALIDO',         'O arquivo PDF possui conteúdo inválido. Não é possível extrair a chave da NFSe automaticamente',  'O arquivo PDF possui conteúdo inválido. Não é possível extrair a chave da NFSe automaticamente'),
     ('PROCESSADO_SUCESSO',   'Processado com sucesso!',                                                                        'Processado com sucesso!');

    INSERT INTO dbo.tb_pag_nfse_motivo_reprovacao
        (mtr_ds_chave, mtr_ds_descricao, mtr_ds_mensagem_padrao, mtr_in_ativo)
    SELECT m.chave, m.descricao, m.mensagem, 1
    FROM @motivos m
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.tb_pag_nfse_motivo_reprovacao t
        WHERE CAST(t.mtr_ds_descricao AS varchar(150)) = m.descricao
    );

    PRINT 'SUCESSO: Seed de motivos NFSe executado. Total: '
        + CAST((SELECT COUNT(*) FROM dbo.tb_pag_nfse_motivo_reprovacao) AS varchar(10));

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
