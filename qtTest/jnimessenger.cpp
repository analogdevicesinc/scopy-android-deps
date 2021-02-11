#include "jnimessenger.h"
#ifdef __ANDROID__

#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#include <QDebug>
#include <libusb.h>

JniMessenger *JniMessenger::m_instance = nullptr;

static void callFromJava(JNIEnv *env, jobject /*thiz*/, jstring value)
{
    Q_EMIT JniMessenger::instance()->messageFromJava(env->GetStringUTFChars(value, nullptr));
}

JniMessenger::JniMessenger(QObject *parent) : QObject(parent),
	obj("org/qtproject/example/jnimessenger/JniMessenger")

{
    m_instance = this;

    JNINativeMethod methods[] {{"callFromJava", "(Ljava/lang/String;)V", reinterpret_cast<void *>(callFromJava)}};
    QAndroidJniObject javaClass("org/qtproject/example/jnimessenger/JniMessenger");

    QAndroidJniEnvironment env;
    jclass objectClass = env->GetObjectClass(javaClass.object<jobject>());
    env->RegisterNatives(objectClass,
			 methods,
			 sizeof(methods) / sizeof(methods[0]));
    env->DeleteLocalRef(objectClass);
}

int JniMessenger::getUsbFd(const QString &message)
{
	auto val = obj.callMethod<jint>("getUsbFd",
					   "(Landroid/content/Context;)I",
					    QtAndroid::androidActivity().object());
	qDebug()<<"got fd in Qt"<<val;

	auto string = obj.callObjectMethod<jstring>("getUsbFs");

	QString qstring = string.toString();
	qDebug()<<"usbfs: "<<qstring;

	if(val == -1 )
		return val;
	auto fd = val;

	libusb_context *g_libusb_context;
	int libusb_error;
	libusb_error = libusb_init(&g_libusb_context);

	libusb_device *dev;

//	dev = libusb_get_device2(g_libusb_context, qstring.toStdString().c_str());

	libusb_device_handle *hdl;

	//qDebug()<<"libusb_open2 returned " << libusb_error_name(libusb_open2(dev,&hdl,fd));

	return val;

}

void JniMessenger::printFromJava(const QString &message)
{
    QAndroidJniObject javaMessage = QAndroidJniObject::fromString(message);
    QAndroidJniObject::callStaticMethod<void>("org/qtproject/example/jnimessenger/JniMessenger",
				       "printFromJava",
				       "(Ljava/lang/String;)V",
					javaMessage.object<jstring>());
}


/*
void JniMessenger::getUsbFd(const QString &message)
{
	QAndroidJniObject javaMessage = QAndroidJniObject::fromString(message);
	QAndroidJniObject::callStaticMethod<void>("org/qtproject/example/jnimessenger/JniMessenger",
					   "getUsbFd",
					   "(Ljava/lang/String;)V",
					    javaMessage.object<jstring>());
}*/

#endif
