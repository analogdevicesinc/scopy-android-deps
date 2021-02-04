#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include "iio.h"

#include <QDebug>


#include <libm2k/m2k.hpp>
#include <libm2k/contextbuilder.hpp>
#include <libm2k/analog/m2kpowersupply.hpp>
#include <libm2k/analog/m2kanalogin.hpp>

using namespace std;
using namespace libm2k;
using namespace libm2k::analog;
using namespace libm2k::context;

#define URI "ip:192.168.2.1"

#define PS_CHANNEL (0)
#define PS_VOLTAGE (1.7)

iio_context *ctx;

MainWindow::MainWindow(QWidget *parent)
	: QMainWindow(parent)
	, ui(new Ui::MainWindow)
{
	ui->setupUi(this);
	unsigned int maj,min;
	char tag[20];
	iio_library_get_version(&maj,&min,tag);
	QString library_version("libiio version: " + QString::number(maj)+"."+QString::number(min)+"\n");
	library_version+=("libm2k version: "+ QString::fromStdString(getVersion()));
	library_version+="\n";
	library_version+="Default URI:"+QString(URI);

	ui->label->setText(library_version);
	ui->textEdit->setText("Click button to connect ...");
	ui->textEdit->setReadOnly(true);
}

MainWindow::~MainWindow()
{
	delete ui;
}


void MainWindow::on_pushButton_libiio_clicked()
{
	unsigned int major,minor;
	const char *name;
	const char *value;

	std::map<std::string,std::string> m_context_attributes;
	char tag[20];
	ctx=iio_create_context_from_uri(URI);
	iio_context_get_version(ctx, &major, &minor, tag);
	unsigned int attr_no = iio_context_get_attrs_count(ctx);

	for (unsigned int i = 0; i < attr_no; i++) {
			 std::pair<std::string, std::string> pair;
			 int ret = iio_context_get_attr(ctx, i, &name, &value);

			 pair.first = std::string(name);
			 pair.second = std::string(value);
			 m_context_attributes.insert(pair);
	 }

	QString output;
	for( auto a : m_context_attributes)
	{
		output.append(QString::fromStdString(a.first)+": "+QString::fromStdString(a.second)+QString("\n"));
	}
	ui->textEdit->setText(output);
	iio_context_destroy(ctx);

}

void MainWindow::on_pushButton_libm2k_clicked()
{
		M2k *ctx = m2kOpen(URI);
		ui->textEdit->setText("");
		ui->textEdit->insertPlainText("Connected  " + QString(URI) + "\n");
		ui->textEdit->insertPlainText(QString::fromStdString(ctx->getContextDescription())+"\n");
		if (!ctx) {
			ui->textEdit->setText("Connection Error: No ADALM2000 device available/connected to your PC.");
			return;
		}
		ui->textEdit->insertPlainText("Calibrating... \n");

		QCoreApplication::processEvents();
		ctx->calibrateADC();


		// Will turn on the power supply if we need smth to measure
		M2kPowerSupply *ps = ctx->getPowerSupply();
		ps->enableChannel(PS_CHANNEL, true);
		ps->pushChannel(PS_CHANNEL, PS_VOLTAGE);
		ui->textEdit->insertPlainText("Setting powersupply channel " + QString::number(PS_CHANNEL) + " to " + QString::number(PS_VOLTAGE)  + "\n");

		// Setup analog in
		M2kAnalogIn *ain = ctx->getAnalogIn();
		ain->enableChannel(0, true);

		double voltage = ain->getVoltage(0);

		ui->textEdit->insertPlainText("Analog in voltage: " + QString::number(voltage)  + "\n");

		contextClose(ctx);
}
