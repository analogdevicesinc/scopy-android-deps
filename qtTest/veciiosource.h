#ifndef VECIIOSOURCEUI_H
#define VECIIOSOURCEUI_H


#include <mainwindow.h>
#include "ui_veciiosource.h"
#include <QWidget>
#include <iio.h>
#include <QThread>

namespace Ui {
class VecIioSourceUi;
}

class VecIioSourceUi : public QWidget
{
	Q_OBJECT

public:
	explicit VecIioSourceUi(adiscope::DataSource *ds, QWidget *parent = nullptr);
	~VecIioSourceUi();
	void startWorkInAThread();
	QThread *qth;

private Q_SLOTS:
	void on_pushButton_clicked();

private:
	Ui::VecIioSourceUi *ui;
	adiscope::DataSource *ds;
};


class WorkerThread : public QThread
{
	Q_OBJECT
	bool running;
	iio_buffer* m_buf;
public:

	WorkerThread(QObject *parent = nullptr) : QThread(parent) , running(false) {}


	void run() override;
	bool getRunning() const;
	void setRunning(bool newRunning);

	iio_buffer *buf() const;
	void setBuf(iio_buffer *newBuf);

Q_SIGNALS:
	void resultReady(const QString &s);
};


#endif // VECIIOSOURCEUI_H
