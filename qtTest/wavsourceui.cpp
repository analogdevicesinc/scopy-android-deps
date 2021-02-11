#include "wavsourceui.h"
#include "ui_wavsourceui.h"
#include <gnuradio/blocks/wavfile_source.h>
#include <QFileDialog>

WavSourceUi::WavSourceUi(adiscope::DataSource *ds, QWidget *parent) :
	QWidget(parent),
	ds(ds),
	ui(new Ui::WavSourceUi)
{
	ui->setupUi(this);
}

WavSourceUi::~WavSourceUi()
{
	delete ui;
}

void WavSourceUi::on_pushButton_clicked()
{
	QString fileName = QFileDialog::getOpenFileName(this,
	    tr("Open Wav"), "/home/adi");
	ui->lineEdit->setText(fileName);
}


void WavSourceUi::on_pushButton_2_clicked()
{

	//auto wav = gr::blocks::wavfile_source::make(ui->lineEdit->text().toStdString().c_str());
	 auto wav = gr::blocks::wavfile_source::make("/home/adi/build-alsa-test-Desktop-Debug/happy.wav");
	ds->man->getTopBlock("test")->replaceBlock(ds->block,wav);
	ds->block = wav;
	ui->label->setText("load finsihed");


}

