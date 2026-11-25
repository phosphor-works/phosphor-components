// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

// The compiled catalogs resolve the components' qsTr() strings under their
// component contexts, and the English one supplies the plural forms that the
// source text alone cannot.

#include <QCoreApplication>
#include <QTest>
#include <QTranslator>

class TestComponentsTranslations : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void englishCarriesThePluralForms()
    {
        QTranslator translator;
        QVERIFY(translator.load(QStringLiteral("phosphor-components_en"), QStringLiteral(PHOSPHOR_COMPONENTS_QM_DIR)));
        QCoreApplication::installTranslator(&translator);
        QCOMPARE(QCoreApplication::translate("ParameterSection", "%n parameter. Click to expand.",
                                             "@info:tooltip collapsed section", 3),
                 QStringLiteral("3 parameters. Click to expand."));
        QCOMPARE(QCoreApplication::translate("ParameterSection", "%n parameter. Click to expand.",
                                             "@info:tooltip collapsed section", 1),
                 QStringLiteral("1 parameter. Click to expand."));
        QCoreApplication::removeTranslator(&translator);
    }

    void germanTranslatesUnderTheComponentContext()
    {
        QTranslator translator;
        QVERIFY(translator.load(QStringLiteral("phosphor-components_de"), QStringLiteral(PHOSPHOR_COMPONENTS_QM_DIR)));
        QCoreApplication::installTranslator(&translator);
        QCOMPARE(
            QCoreApplication::translate("ShaderErrorBanner", "Shader failed to load", "@info:status shader preview"),
            QStringLiteral("Shader konnte nicht geladen werden"));
        QCoreApplication::removeTranslator(&translator);
    }
};

QTEST_GUILESS_MAIN(TestComponentsTranslations)
#include "test_components_translations.moc"
