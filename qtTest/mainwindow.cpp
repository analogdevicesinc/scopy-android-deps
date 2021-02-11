#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include "iio.h"
#include "config.h"
#include <gnuradio/constants.h>
#include <gnuradio/blocks/wavfile_source.h>
#include "gnuradio/blocks/throttle.h"
#include "gnuradio/blocks/nop.h"
#include "scope_sink_f.h"
#include "vectordatasourceui.h"
#include "wavsourceui.h"
#include "veciiosource.h"
#include "iiosourceui.h"
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
#include <gnuradio/hier_block2.h>
#include <iio/device_source.h>
#include <gnuradio/blocks/short_to_float.h>
#include <stream_to_vector_overlap.h>
#include <gnuradio/blocks/vector_sink.h>
#include <QTimer>
#ifdef __ANDROID__
	#include "jnimessenger.h"
#include <libusb.h>
#endif



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

using namespace adiscope;

DataSource DataSourceFactory::createDataSource(IioManager* man, QString type, int outputs)
{
	static int i=0;
	auto scopyTop = man->getTopBlock("test");

	gr::basic_block_sptr src;
	if(type == "vector") {
		auto vecsrc = gr::blocks::vector_source<float>::make({});// dynamic_pointer_cast<gr::blocks::vector_source<float>>(scopyTop->addVectorSource(testData[i%2]));
		src = vecsrc;
	} else if(type == "wav") {
		auto wavsrc =  gr::blocks::vector_source<float>::make({});// gr::blocks::wavfile_source::make(""); // placeholder
		//auto wavsrc = gr::blocks::wavfile_source::make("/home/adi/build-alsa-test-Desktop-Debug/happy.wav");
		src = wavsrc;

	} else if(type == "iio") {
		auto iiosrc = gr::blocks::vector_source<float>::make({});

		src = iiosrc;

	} else if(type == "vec-iio") {
		auto iiosrc = gr::blocks::vector_source<float>::make({});
		src = iiosrc;
	}

	else { ;}

	i++;
	DataSource ds;
	ds.block = src;
	ds.outputs = outputs;
	ds.man = man;
	ds.name = "";
	scopyTop->addSource(src);
	return ds;
}

DataSourceUi DataSourceFactory::createDataSourceUi(DataSource* ds, QString type, QWidget *parent)
{
	QWidget *ret;
	if(type == "vector") {
	//	ret = new VectorDataSourceUi();
		ret = new VectorDataSourceUi(ds, parent);
	} else if(type=="wav") {
		ret = new WavSourceUi(ds, parent);
	} else if(type =="iio") {
		ret = new IioSourceUi(ds, parent);
	} else if(type =="iio") {
		ret = new VecIioSourceUi(ds, parent);
	} else {; }

	DataSourceUi ui;
	ui.widget = ret;
	ui.ds = ds;
	return ui;


}

void MainWindow::gnuradioTest()
{
	man = new adiscope::IioManager(this);
	man->addTopBlock("test");
	auto scopyTop = man->getTopBlock("test");


	std::vector<float> testData[2];
	int test_nr_of_samples  = 1024;
	for(auto i=0;i<test_nr_of_samples;i++)
	{
		testData[0].push_back(i/(float)test_nr_of_samples);
		testData[1].push_back((test_nr_of_samples-i)/(float)test_nr_of_samples);
	}
	auto vec_src = gr::blocks::vector_source<float>::make(testData[0]);
	vec_src->set_repeat(true);
	auto th = gr::blocks::throttle::make(sizeof(float),2000);
	auto s2vo = stream_to_vector_overlap::make(sizeof(float),testData[0].size()/2,0);
	auto vs = gr::blocks::vector_sink<float>::make(testData[0].size()/2);

	//scopyTop->connect(vec_src,0,s2vo,0);
	//scopyTop->connect(s2vo,0,vs,0);
	scopyTop->connect(vec_src,0,th,0);
	scopyTop->connect(th,0,s2vo,0);
	scopyTop->connect(s2vo,0,vs,0);


	QTimer *timer = new QTimer(this);
	connect(timer,&QTimer::timeout,this,[=]{
		//qDebug()<<vs->data().size();
		vs->reset();
	});
	timer->start(500);


	/*scope_sink[0] = scope_sink_f::make(nb_points,sample_rate,"bla0",1,scopyPlot);
	scope_sink[1] = scope_sink_f::make(nb_points,sample_rate,"bla1",1,scopyPlot);*/

	/*auto th = gr::blocks::throttle::make(sizeof(float),32000);
	scopyTop->connect(vec,0,th,0);
	scopyTop->connect(th,0,scope_sink,0);*/

	/*for(auto i = 0;i < scopyTop->getNrOfSources();i++)
	{
		scopyTop->connect(vec[i],0,scope_sink[i],0);
	}*/

/*	scopyPlot->registerSink(scope_sink[0]->name(),1,nb_points);
	scopyPlot->registerSink(scope_sink[1]->name(),1,nb_points);*/

/*	scope_sink[0]->set_trigger_mode(TRIG_MODE_FREE, 0, "");
	scope_sink[0]->set_update_time(0.001);*/

	connect(ui->addBtn,SIGNAL(clicked()),this,SLOT(addSource()));
	connect(ui->removeBtn,SIGNAL(clicked()),this,SLOT(removeSource()));

	plotInstrument = new PlotInstrument(scopyTop, ui->plotInstrument, this);

	connect(this,SIGNAL(topBlockChanged()),plotInstrument,SLOT(buildFlowGraph()));


	/////////////
	/// \brief sinkIndex
	///

	//////////


}

void MainWindow::addSource()
{

	QString sinkName = ui->sinkCmb->currentText()+ui->nameEdit->text();

	int i=0;

	bool nameTaken = sources.count(sinkName); // check if name is available
	while(nameTaken) { // if not count through names
		if(!(sources.count(sinkName+"_"+QString::number(i)))) {
			sinkName = sinkName+"_"+QString::number(i);
			nameTaken = false;
		}
	i++;
	};

	DataSourceFactory fac;
	sources[sinkName] = fac.createDataSource(man, ui->sinkCmb->currentText(),1);

	uis[sinkName] = fac.createDataSourceUi(&sources[sinkName], ui->sinkCmb->currentText(), this);

	ui->tabWidget->addTab(uis[sinkName].widget,"Config " + sinkName);
	ui->sinkList->addItem(sinkName);
	Q_EMIT topBlockChanged();

}

void MainWindow::removeSource()
{
	if(ui->sinkList->selectedItems().isEmpty()) {
		qDebug()<<"Nothing selected in list";
		return;
	}
	QString toRemove = ui->sinkList->currentItem()->text();
	int i=0;
	for(i=0;i<ui->tabWidget->count();i++)
		if(ui->tabWidget->widget(i)==uis[toRemove].widget)
			break;

	ui->tabWidget->removeTab(i);

	delete uis[toRemove].widget;

	QListWidgetItem *it = ui->sinkList->takeItem(ui->sinkList->currentRow());
	delete it;

	auto scopyTop = man->getTopBlock("test");
	scopyTop->deleteSource(sources[toRemove].block);
	sources.erase(toRemove);
	uis.erase(toRemove);
	Q_EMIT topBlockChanged();

}

MainWindow::MainWindow(QWidget *parent)
	: QMainWindow(parent)
	, ui(new Ui::MainWindow)
#ifdef __ANDROID__
	, jnienv(new QAndroidJniEnvironment())
#endif

{

	ui->setupUi(this);
#ifdef __ANDROID__
	int retval = libusb_set_option(NULL,LIBUSB_OPTION_ANDROID_JAVAVM,jnienv->javaVM());
	if (0 < retval)
	{
		qDebug()<< " - ERROR in libusb_set_option: " << retval;
	}

	retval = libusb_set_option(NULL, LIBUSB_OPTION_WEAK_AUTHORITY, NULL);
	if (0 < retval)
	{
		qDebug()<< " - ERROR in libusb_set_option: " << retval;
	}

#endif

	unsigned int maj,min;
	char tag[20];
	iio_library_get_version(&maj,&min,tag);
	QString backend = "";
	for(auto i=0;i<iio_get_backends_count();i++)
	{
		backend+=iio_get_backend(i);
		backend+=" ";
	}
	QString library_version("libiio version: " + QString::number(maj)+"."+QString::number(min)+" with backends: "+backend+"\n");
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

	gnuradioTest();

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

void MainWindow::on_pushButton_2_clicked()
{

	/*JniMessenger *jniMessenger = new JniMessenger(this);
	jniMessenger->printFromJava("ABCD");
	jniMessenger->getUsbFd("abc");*/

	struct iio_context_info **info;
		unsigned int nb_contexts;
		QStringList uris;

		struct iio_scan_context *scan_ctx = iio_create_scan_context("usb", 0);

		if (!scan_ctx) {
			std::cerr << "Unable to create scan context!" << std::endl;
			return;

		}

		ssize_t ret = iio_scan_context_get_info_list(scan_ctx, &info);

		if (ret < 0) {
			std::cerr << "Unable to scan!" << std::endl;
			goto out_destroy_context;
		}

		nb_contexts = static_cast<unsigned int>(ret);
		qDebug()<<nb_contexts << "contexts found ";
		for (unsigned int i = 0; i < nb_contexts; i++)
			uris.append(QString(iio_context_info_get_uri(info[i])));

		iio_context_info_list_free(info);
	out_destroy_context:
		iio_scan_context_destroy(scan_ctx);
		ui->textEdit->setText(uris.join(" "));

}

