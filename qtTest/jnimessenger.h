
#ifndef MYCLASS_H
#define MYCLASS_H

#ifdef __ANDROID__

#include <QObject>
#include <QAndroidJniObject>

class JniMessenger : public QObject
{
    Q_OBJECT

public:
    explicit JniMessenger(QObject *parent = nullptr);
    static JniMessenger *instance() { return m_instance; }
    Q_INVOKABLE void printFromJava(const QString &message);
    Q_INVOKABLE int getUsbFd(const QString &message);
    QAndroidJniObject obj;

Q_SIGNALS:
    void messageFromJava(const QString &message);

public Q_SLOTS:

private:
    static JniMessenger *m_instance;
};
#endif

#endif // MYCLASS_H
