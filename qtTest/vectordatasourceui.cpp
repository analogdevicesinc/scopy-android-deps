#include "vectordatasourceui.h"
#include "ui_vectordatasourceui.h"
#include <memory>
#include <boost/shared_ptr.hpp>
#include <boost/pointer_cast.hpp>


VectorDataSourceUi::VectorDataSourceUi(adiscope::DataSource *ds, QWidget *parent) :
	ds(ds),
	QWidget(parent),
	ui(new Ui::VectorDataSourceUi)
{
	ui->setupUi(this);

	int test_nr_of_samples  = 1024;
	for(auto i=0;i<test_nr_of_samples;i++)
	{
		testData[0].push_back(i/(float)test_nr_of_samples);
		testData[1].push_back((test_nr_of_samples-i)/(float)test_nr_of_samples);
	}

}

VectorDataSourceUi::~VectorDataSourceUi()
{
	delete ui;
}

void VectorDataSourceUi::on_comboBox_currentIndexChanged(int index)
{
    auto src = boost::dynamic_pointer_cast<gr::blocks::vector_source<float>>(ds->block);
    src->set_data(testData[index]);
}


void VectorDataSourceUi::on_checkBox_stateChanged(int arg1)
{
	auto src = boost::dynamic_pointer_cast<gr::blocks::vector_source<float>>(ds->block);
	src->set_repeat(arg1);
}

