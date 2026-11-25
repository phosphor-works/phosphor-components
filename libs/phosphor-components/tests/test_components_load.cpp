// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

// Every component of Phosphor.Components loads and instantiates. In this
// repository's tree org.phosphor.animation (phosphor-libs) is linked in, so
// every load error fails. Only a configure of this library on its own, without
// phosphor-libs, skips the components that import it.

#include <QFileInfo>
#include <QHash>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QTest>
#include <QtQml/QQmlExtensionPlugin>

Q_IMPORT_QML_PLUGIN(Phosphor_ComponentsPlugin)
#ifdef PHOSPHOR_COMPONENTS_WITH_ANIMATION
Q_IMPORT_QML_PLUGIN(org_phosphor_animationPlugin)
#endif

class TestComponentsLoad : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void load_data()
    {
        QTest::addColumn<QString>("name");
        const QStringList files = QString::fromUtf8(PHOSPHOR_COMPONENTS_QML_FILES).split(QLatin1Char('|'));
        QVERIFY(files.size() > 1);
        for (const QString& file : files) {
            const QString name = QFileInfo(file).completeBaseName();
            QTest::newRow(qPrintable(name)) << name;
        }
    }

    void load()
    {
        QFETCH(QString, name);
        QQmlEngine engine;
        QQmlComponent component(&engine);
        // Components with required properties get what a host passes: real
        // shapes, so their delegates (zones, parameter rows) are built too.
        static const QString kZone =
            QStringLiteral("{ relativeGeometry: { x: 0, y: 0, width: 0.5, height: 1 }, zoneNumber: 1 }");
        static const QString kParameters = QStringLiteral(
            "parameters: [{ id: \"speed\", name: \"Speed\", type: \"float\", group: \"Motion\", "
            "default: 1.0, min: 0, max: 2, step: 0.1 }]; currentValues: ({ speed: 1.0 })");
        static const QHash<QString, QString> requiredProperties{
            {QStringLiteral("AxisChevron"),
             QStringLiteral("direction: 0; arm: 6; thickness: 1; strokeColor: \"white\"")},
            {QStringLiteral("CategoryMenuButton"), QStringLiteral("items: []")},
            {QStringLiteral("ParameterRow"),
             QStringLiteral("paramData: ({ id: \"p\", name: \"P\", type: \"float\" }); currentValues: ({ p: 0.5 })")},
            {QStringLiteral("ParameterSection"), QStringLiteral("title: \"Colours\"")},
            {QStringLiteral("ParameterEditor"), kParameters},
            {QStringLiteral("ShaderParamsEditor"), kParameters},
            {QStringLiteral("ZonePreview"), QStringLiteral("zones: [") + kZone + QStringLiteral("]")},
            {QStringLiteral("LayoutCard"),
             QStringLiteral("previewWidth: 160; previewHeight: 90; layoutData: ({ displayName: \"Halves\", "
                            "category: 0, zones: [")
                 + kZone + QStringLiteral("] })")},
        };
        const QString source = name == QLatin1String("ZoneColorDefaults")
            ? QStringLiteral(
                  "import QtQuick\nimport Phosphor.Components\nQtObject { property var c: ZoneColorDefaults }\n")
            : QStringLiteral("import QtQuick\nimport Phosphor.Components\n%1 { %2 }\n")
                  .arg(name, requiredProperties.value(name));
        component.setData(source.toUtf8(), QUrl(QStringLiteral("inline.qml")));
        if (component.isError()) {
            const QString errors = component.errorString();
#ifndef PHOSPHOR_COMPONENTS_WITH_ANIMATION
            if (errors.contains(QLatin1String("org.phosphor.animation")) && !animationAvailable(engine)) {
                QSKIP("needs org.phosphor.animation (phosphor-libs), which this build does not have");
            }
#endif
            QFAIL(qPrintable(errors));
        }
        std::unique_ptr<QObject> object(component.create());
        QVERIFY2(object, qPrintable(component.errorString()));
    }

private:
    static bool animationAvailable(QQmlEngine& engine)
    {
        QQmlComponent probe(&engine);
        probe.setData("import org.phosphor.animation\nimport QtQuick\nQtObject {}\n",
                      QUrl(QStringLiteral("probe.qml")));
        return !probe.isError();
    }
};

QTEST_MAIN(TestComponentsLoad)
#include "test_components_load.moc"
