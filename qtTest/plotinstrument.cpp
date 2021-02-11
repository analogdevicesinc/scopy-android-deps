#include "plotinstrument.h"

using namespace adiscope;

PlotInstrument::PlotInstrument(boost::shared_ptr<ScopyTopBlock> top, QWidget *topLvlWidget, QObject *parent) :
	QObject(parent), topLvlWidget(topLvlWidget), top(top), ui(new Ui::PlotInstrument)
{

	/*vec[0] = dynamic_pointer_cast<gr::blocks::vector_source<float>>(scopyTop->addVectorSource(testData[0]));
	vec[1] = dynamic_pointer_cast<gr::blocks::vector_source<float>>(scopyTop->addVectorSource(testData[1]));
	vec[0]->set_repeat(false);
	vec[1]->set_repeat(true);*/

	nb_points = 1023;
	sample_rate = 1000;

	ui->setupUi(topLvlWidget);
	scopyPlot = new CapturePlot(ui->plotPlaceholder);
	scopyPlot->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
	ui->plotPlaceholder->layout()->addWidget(scopyPlot);

	//scopyPlot->set
	scopyPlot->setHorizUnitsPerDiv((double) nb_points /
				       ((double) sample_rate)/10);
	scopyPlot->setSampleRate(sample_rate,1,"");
	scopyPlot->setDataStartingPoint(-(nb_points/2));
	scopyPlot->axisWidget(QwtPlot::yLeft)->scaleDraw()->setMinimumExtent(65);

	//scope_sink->set_displayOneBuffer(true);
	//scopyPlot->addZoomer(0);
	//scopyPlot->setZoomerEnabled(true);

	scopyPlot->disableLegend();
	connect(ui->runBtn, SIGNAL(clicked()),this,SLOT(run()));
	connect(ui->stopBtn, SIGNAL(clicked()),this,SLOT(stop()));

	QSpacerItem *plotSpacer = new QSpacerItem(0, 5,
						  QSizePolicy::Fixed, QSizePolicy::Fixed);
	ui->gridLayoutPlot->addWidget(scopyPlot->topArea(), 1, 0, 1, 4);
	ui->gridLayoutPlot->addWidget(scopyPlot->topHandlesArea(), 2, 0, 1, 4);

	ui->gridLayoutPlot->addWidget(scopyPlot->leftHandlesArea(), 1, 0, 4, 1);
	ui->gridLayoutPlot->addWidget(scopyPlot->rightHandlesArea(), 1, 3, 4, 1);

	ui->gridLayoutPlot->addWidget(scopyPlot, 3, 1, 1, 1);
	ui->gridLayoutPlot->addWidget(scopyPlot->bottomHandlesArea(), 4, 0, 1, 4);
	ui->gridLayoutPlot->addItem(plotSpacer, 5, 0, 1, 4);

}

void PlotInstrument::buildFlowGraph(){
	unsigned int i;

	unbuildFlowGraph();

	// each synced blocks should belong to the same scope_sink ..
	// ref channels should not be part of the same scope_sink while math should - this is instrument specific

	scopyPlot->setActiveVertAxis(0);


	for(i = 0;i < top->getNrOfSources();i++) {
		std::string sinkName = top->getSources()[i]->name() + std::to_string(i);
		qDebug()<<QString(sinkName.c_str());
		scope_sink_f::sptr sink = scope_sink_f::make(nb_points, sample_rate, sinkName, 1, scopyPlot);
		top->connect(top->getSources()[i], 0, sink, 0);
		//scopyPlot->registerSink(sink->name(),1,nb_points);
		scopyPlot->registerSink(sink->name(), 1, 0);
		scopyPlot->disableLegend();
		scopyPlot->setOffsetHandleVisible(i, true);
		scopyPlot->setOffsetWidgetVisible(i, true);
		scopyPlot->setUsingLeftAxisScales(true);

		sink->set_trigger_mode(TRIG_MODE_FREE, 0, "");
		sink->set_update_time(0.1);
		scope_sink.push_back(sink);

		scopyPlot->Curve(i)->setAxes(
						QwtAxisId(QwtPlot::xBottom, 0),
						QwtAxisId(QwtPlot::yLeft, i));
		scopyPlot->addZoomer(i);

	}


	/*scopyPlot->enableAxis(QwtAxisId(QwtPlot::yLeft),i), false);
	scopyPlot->enableAxis(QwtPlot::xBottom, false);*/
	scopyPlot->setUsingLeftAxisScales(false);
	//scopyPlot->replot();
}

void PlotInstrument::unbuildFlowGraph() {
	unsigned int i;

	for(i=0;i<scope_sink.size();i++) {
		scopyPlot->unregisterSink(scope_sink[i]->name());
		top->del_connection(scope_sink[i], true);
	}
	scope_sink.clear();
}

void PlotInstrument::run() {
	qDebug()<<"unlocked top flowgraph";
	top->lock();
	top->unlock();
}

void PlotInstrument::stop() {
	qDebug()<<"locked top flowgraph";
	top->lock();
}

PlotInstrument::~PlotInstrument()
{

}
