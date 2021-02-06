#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include "iio.h"
#include "config.h"
#include <gnuradio/constants.h>

#include <QDebug>


#include <libm2k/m2k.hpp>
#include <libm2k/contextbuilder.hpp>
#include <libm2k/analog/m2kpowersupply.hpp>
#include <libm2k/analog/m2kanalogin.hpp>



#include <qwt_plot.h>
#include <qwt_plot_curve.h>
#include <qwt_plot_grid.h>
#include <qwt_symbol.h>
#include <qwt_legend.h>



using namespace std;
using namespace libm2k;
using namespace libm2k::analog;
using namespace libm2k::context;

#define URI "ip:192.168.2.1"
QString Uri = URI;


#define PS_CHANNEL (0)
#define PS_VOLTAGE (1.7)

iio_context *ctx;


QwtPlot *plot;
MainWindow::MainWindow(QWidget *parent)
	: QMainWindow(parent)
	, ui(new Ui::MainWindow)
{
	ui->setupUi(this);
	unsigned int maj,min;
	char tag[20];
	iio_library_get_version(&maj,&min,tag);
	QString library_version("libiio version: " + QString::number(maj)+"."+QString::number(min)+"\n");
	library_version+=("libm2k version: "+ QString::fromStdString(getVersion())+"\n");
	library_version+=("gnuradio version "+ QString::fromStdString(gr::version()));

	library_version+="\ncompiled @ " + QString(__TIME__) + " for " + QString(TARGET_SYS_NAME) + " " + QString(TARGET_PROCESSOR) + "\n";


	ui->label->setText(library_version);
	ui->textEdit->setText("Click button to connect ...");
	ui->textEdit->setReadOnly(true);
	ui->lineEdit_uri->setText(Uri);
	ui->label_uri->setText("Connecting to: " +QString(Uri));

	plot = new QwtPlot(this);
	plot->setTitle( "Plot Demo" );
	    plot->setCanvasBackground( Qt::white );
	    plot->setAxisScale( QwtAxis::yLeft, 0.0, 10.0 );
	    plot->insertLegend( new QwtLegend() );

	    QwtPlotGrid *grid = new QwtPlotGrid();
	    grid->attach( plot );

	    QwtPlotCurve *curve = new QwtPlotCurve();
	    curve->setTitle( "Some Points" );
	    curve->setPen( Qt::blue, 4 ),
	    curve->setRenderHint( QwtPlotItem::RenderAntialiased, true );

	    QwtSymbol *symbol = new QwtSymbol( QwtSymbol::Ellipse,
		QBrush( Qt::yellow ), QPen( Qt::red, 2 ), QSize( 8, 8 ) );
	    curve->setSymbol( symbol );

	    QPolygonF points;
	    points << QPointF( 0.0, 4.4 ) << QPointF( 1.0, 3.0 )
		<< QPointF( 2.0, 4.5 ) << QPointF( 3.0, 6.8 )
		<< QPointF( 4.0, 7.9 ) << QPointF( 5.0, 7.1 );
	    curve->setSamples( points );

	    curve->attach( plot );

	    plot->resize( 600, 400 );
	    plot->show();
	ui->plotLayout->insertWidget(0,plot);


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
	ctx=iio_create_context_from_uri(Uri.toStdString().c_str());
	if(!ctx)
	{
		ui->textEdit->setText("No IIO device found at uri: " + Uri);
		return;
	}
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
		M2k *ctx = m2kOpen(Uri.toStdString().c_str());
		ui->textEdit->setText("");
		if (!ctx) {
			ui->textEdit->setText("Connection Error: No ADALM2000 device available/connected to your PC.");
			return;
		}
		ui->textEdit->insertPlainText("Connected  " + QString(Uri) + "\n");
		ui->textEdit->insertPlainText(QString::fromStdString(ctx->getContextDescription())+"\n");
		ui->textEdit->insertPlainText("Calibrating... \n");

		QCoreApplication::processEvents();
		//ctx->calibrateADC(); // this needs to be in a separate thread as the hanging thread crashes on native android


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

void MainWindow::on_pushButton_clicked()
{
    Uri = ui->lineEdit_uri->text();
    ui->label_uri->setText("Connecting to: " +QString(Uri));
}
