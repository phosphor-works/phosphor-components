// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

// Every type of Phosphor.Design loads and instantiates, and gives no QML
// warning. The file list comes from CMake, so a new file is tested without a
// change here.

#include <QFileInfo>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QRegularExpression>
#include <QSet>
#include <QTest>
#include <QtQml/QQmlExtensionPlugin>

Q_IMPORT_QML_PLUGIN(Phosphor_DesignPlugin)

class TestDesignLoad : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void load_data()
    {
        QTest::addColumn<QString>("name");
        const QStringList files = QString::fromUtf8(PHOSPHOR_DESIGN_QML_FILES).split(QLatin1Char('|'));
        QVERIFY(files.size() > 1);
        for (const QString& file : files) {
            const QString name = QFileInfo(file).completeBaseName();
            QTest::newRow(qPrintable(name)) << name;
        }
    }

    void load()
    {
        QFETCH(QString, name);
        // A QML warning names its file and line. A binding that reads a name
        // that does not exist gives one. A token that does not exist gives
        // none where the property is a color, so this test does not find it.
        QTest::failOnWarning(QRegularExpression(QStringLiteral("\\.qml:\\d+")));

        static const QSet<QString> singletons{QStringLiteral("Icons"), QStringLiteral("Metrics"),
                                              QStringLiteral("Motion"), QStringLiteral("Theme")};
        const QString source = singletons.contains(name)
            ? QStringLiteral("import QtQuick\nimport Phosphor.Design\nQtObject { property var token: %1 }\n").arg(name)
            : QStringLiteral("import QtQuick\nimport Phosphor.Design\n%1 {}\n").arg(name);

        QQmlEngine engine;
        QQmlComponent component(&engine);
        component.setData(source.toUtf8(), QUrl(QStringLiteral("inline.qml")));
        QVERIFY2(!component.isError(), qPrintable(component.errorString()));
        std::unique_ptr<QObject> object(component.create());
        QVERIFY2(object, qPrintable(component.errorString()));
        if (singletons.contains(name)) {
            QVERIFY2(object->property("token").value<QObject*>(), "the singleton did not load");
        }
    }
};

QTEST_MAIN(TestDesignLoad)
#include "test_design_load.moc"
