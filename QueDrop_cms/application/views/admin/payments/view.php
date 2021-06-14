<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4></i> <span class="text-semibold">Payment Details</span></h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li class="active">Payment Details</li>
		</ul>
	</div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
    <!-- Panel -->
    <div class="panel panel-flat">
        <!-- Listing table -->
        <div class="panel-body table-responsive">
            <div class="col-md-12">
                <!-- <form action="<?php echo base_url('admin/payments/get_details'); ?>" method="POST" id="settings_form" name="settings_form"> -->
                    <div class="row">
                        <div class="form-group">
                            <div class="deta_get">
                                <div class="col-md-6">
                                <label class="t_lbl">Week Start Date:</label>
                                <input type ="text" id = "datepicker-13" name="datepicker" class="form-control date_pi" placeholder="Select Start Date">
                                </div>
                                <div class="col-md-6">
                                <label class="t_lbl">Week End Date:</label>
                                <input type ="text" id = "datepicker-14" name="datepicker2" class="form-control date_pi" placeholder="Select End Date">
                                </div>
                            </div>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-success" onclick="get_orders();">Submit</button>			
                    
                <!-- </form> -->
            </div>
        </div>
        <!-- /Listing table -->
    </div>
    <!-- /Panel -->
    <div id="order_details"></div>
</div>
<style>
.deta_get{
    display:inline-flex;
    width:100%;
}
.t_lbl{
    width:30%;
}

</style>
<!-- /Content area -->
<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>

<!-- Javascript -->
<script>
var base_url = '<?php echo base_url();?>'
function get_orders(){
    $("#order_details").empty();
    var start_date = $("#datepicker-13").val();
    var end_date = $("#datepicker-14").val();
    $.ajax({
    type: "POST",
    url: base_url+"admin/payments/get_details",
    data: {
    'datepicker':start_date,
    'datepicker2':end_date
    },
    success: function(data){
      $("#order_details").append(data);
    }
  });
}

$(function() {

    $("#datepicker-14").datepicker({ beforeShowDay:
    function(dt)
    {
    return [dt.getDay() == 2 ? true : false];
    }
});

$("#datepicker-13").datepicker({ 
    beforeShowDay:
    function(dt)
    {
    return [dt.getDay() == 3 ? true : false];
    },
    onSelect: function(selected) {
        var date = $(this).datepicker('getDate');
        date.setDate(date.getDate() + 6); // Add 7 days
        $("#datepicker-14").datepicker("option", "minDate", selected);
        $("#datepicker-14").datepicker("option", "maxDate", date);
        $('#datepicker-14').val($.datepicker.formatDate('mm/dd/yy', date));
    }
});


});
</script>

