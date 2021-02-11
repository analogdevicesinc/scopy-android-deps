#include "veciiosource.h"
#include "ui_veciiosource.h"

#include <boost/shared_ptr.hpp>
#include <gnuradio/hier_block2.h>

#include <gnuradio/blocks/throttle.h>
#include <gnuradio/io_signature.h>
#include <iio/device_source.h>
#include <gnuradio/blocks/short_to_float.h>
#include <QThread>
#include <QObject>




bool WorkerThread::getRunning() const
{
	return running;
}

void WorkerThread::setRunning(bool newRunning)
{
	running = newRunning;
}

iio_buffer *WorkerThread::buf() const
{
	return m_buf;
}

void WorkerThread::setBuf(iio_buffer *newBuf)
{
	m_buf = newBuf;
}

void WorkerThread::run(){

	running = true;
	while(running)
	{
		iio_buffer_refill(m_buf);


	}
    }

void VecIioSourceUi::startWorkInAThread()
{
    WorkerThread *workerThread = new WorkerThread(this);
  //  connect(workerThread, &WorkerThread::resultReady, this, &VecIioSourceUi::handleResults);
    connect(workerThread, &WorkerThread::finished, workerThread, &QObject::deleteLater);
    workerThread->start();
}

VecIioSourceUi::VecIioSourceUi(adiscope::DataSource *ds, QWidget *parent) :
	QWidget(parent),
	ds(ds),
	ui(new Ui::VecIioSourceUi)
{
	ui->setupUi(this);
}

VecIioSourceUi::~VecIioSourceUi()
{
	delete ui;
}

void VecIioSourceUi::on_pushButton_clicked()
{
	std::string ctx = ui->ctxEdit->text().toStdString();
	std::string dev = ui->devEdit->text().toStdString();
	QStringList sl(ui->devChannel->text().split(" "));
	std::vector<std::string> ch;
	for(auto s : qAsConst(sl)) {
		ch.push_back(s.toStdString());
	}

	iio_context *ctx_iio = iio_create_context_from_uri(ctx.c_str());
	iio_device *dev_iio = iio_context_find_device(ctx_iio,dev.c_str());
	for(auto ch_str : ch) {
		iio_channel *chan = iio_device_find_channel(dev_iio,ch_str.c_str(),false);
		iio_channel_enable(chan);
	}

	/*auto iio_blk = veciio_float_src::make(ctx,dev,ch,"ad9361-phy");
	ds->man->getTopBlock("test")->replaceBlock(ds->block, iio_blk);
	ds->block = iio_blk;*/
	iio_buffer *buf_iio = iio_device_create_buffer(dev_iio,1024,true);

	qth->start();
	iio_buffer_refill(buf_iio);

}


