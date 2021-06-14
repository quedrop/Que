<!-- Page header -->
<div class="page-header page-header-default">
  <div class="page-header-content">
    <div class="page-title">
      <h4>
        <span class="text-semibold"><?php _el('delivery_charge'); ?></span>
      </h4>
    </div>
  </div>
  <div class="breadcrumb-line">
    <ul class="breadcrumb">
      <li>
        <a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
      </li>
      <li class="active">
        <?php _el('delivery_charge'); ?>
      </li>
    </ul>
  </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
  <!-- Panel -->
  <div class="panel panel-flat">
    <?php if (has_permissions('delivery_charge','create') || has_permissions('delivery_charge','delete')) { ?>
      <!-- Panel heading -->
      <div class="panel-heading">
        <?php if (has_permissions('delivery_charge','create')) { ?>
          <a href="<?php echo base_url('admin/delivery_charge/add'); ?>" class="btn btn-primary"><?php _el('add_new'); ?><i class="icon-plus-circle2 position-right"></i></a>
        <?php } ?>
        <?php if (has_permissions('delivery_charge','delete')) { ?>
        <a href="javascript:delete_selected();" class="btn btn-danger" id="delete_selected"><?php _el('delete_selected'); ?><i class=" icon-trash position-right"></i></a>
        <?php } ?>
      </div>
      <!-- /Panel heading -->
    <?php } ?>
    
    <!-- Listing table -->
    <div class="panel-body table-responsive">
      <table id="delivery_charge_table" class="table table-bordered table-striped">
        <thead>
          <tr>
            <?php if (has_permissions('delivery_charge','delete')) { ?>
            <th width="2%">
              <input type="checkbox" name="select_all" id="select_all" class="styled" onclick="select_all(this);" >
            </th>
            <?php } ?>
            <th width="20%"><?php _el('reg_charge_per_km'); ?></th>
            <th width="20%"><?php _el('extra_charge_per_km'); ?></th>
            <th width="20%"><?php _el('status'); ?></th>
            <?php if (has_permissions('delivery_charge','edit') || has_permissions('delivery_charge','delete')) { ?>
            <th width="8%" class="text-center"><?php _el('actions'); ?></th>
            <?php } ?>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($delivery_charge as $key => $order) { ?>
          <tr>
            <?php if (has_permissions('delivery_charge','delete')) { ?>
            <td>
              <input type="checkbox" class="checkbox styled"  name="delete"  id="<?php  echo $order['id']; ?>">
            </td>
            <?php } ?>
            <td><?php echo "$".$order['min_charges'];?></td>
            <td><?php echo "$".$order['extra_per_km'];?></td>
            <td class="text-center switchery-sm">
                <input type="checkbox" onchange="change_status(this);" class="switchery"  id="<?php echo $order['id']; ?>" <?php if ($order['is_active'] == 1) { echo "checked"; } ?> >
            </td>
            <?php if (has_permissions('delivery_charge','edit') || has_permissions('delivery_charge','delete')) { ?>
            <td class="text-center">
              <?php if (has_permissions('delivery_charge','edit')) { ?>
                <a data-popup="tooltip" data-placement="top"  title="<?php _el('edit') ?>" href="<?php echo site_url('admin/delivery_charge/edit/').$order['id']; ?>" id="<?php echo $order['id']; ?>" class="text-info">
                  <i class="icon-pencil7"></i>
                </a>
              <?php } ?>
              <?php if (has_permissions('delivery_charge','delete')) { ?>
                <a data-popup="tooltip" data-placement="top"  title="<?php _el('delete') ?>" href="javascript:delete_record(<?php echo $order['id']; ?>);" class="text-danger delete" id="<?php echo $order['id']; ?>"><i class=" icon-trash"></i></a>
              <?php } ?>
            </td>
            <?php } ?>
          </tr>
          <?php } ?>
        </tbody>
      </table>      
    </div>
    <!-- /Listing table -->
  </div>
  <!-- /Panel -->
</div>
<!-- /Content area -->

<script type="text/javascript">

$(function() {

    $('#delivery_charge_table').DataTable({
        'columnDefs': [ {
        'targets': [0,1], /* column index */
        'orderable': false, /* disable sorting */
        }],
         
    });

    //add class to style style datatable select box
    $('div.dataTables_length select').addClass('datatable-select');
 });  

var BASE_URL = "<?php echo base_url(); ?>";

/**
 * Deletes a single record when clicked on delete icon
 *
 * @param {int}  id  The identifier
 */
function change_status(obj)
{
    var checked = 0;

    if(obj.checked) 
    { 
        checked = 1;
    }  

    $.ajax({
        url:BASE_URL+'admin/delivery_charge/update_status',
        type: 'POST',
        data: {
            user_id: obj.id,
            is_active:checked
        },
        success: function(msg) 
        {
            if (msg=='true')
            {                           
                jGrowlAlert("<?php _el('_activated', _l('delivery_charge')); ?>", 'success');
            }
            else
            {                  
                jGrowlAlert("<?php _el('_deactivated', _l('delivery_charge')); ?>", 'success');
            }
        }
    }); 
}


function delete_record(id) 
{ 
    swal({
        title: "<?php _el('single_deletion_alert'); ?>",
        text: "<?php _el('single_recovery_alert'); ?>",
        type: "warning",  
        showCancelButton: true, 
        cancelButtonText:"<?php _el('no_cancel_it'); ?>",
        confirmButtonText: "<?php _el('yes_i_am_sure'); ?>",       
    },
    function()
    {
            $.ajax({
                url:BASE_URL+'admin/delivery_charge/delete',
                type: 'POST',
                data: {
                    order_id:id
                },
                success: function(msg)
                {
                    if (msg=="true")
                    {                        
                        swal({
                            title: "<?php _el('_deleted_successfully', _l('order')); ?>",
                            type: "success",
                        });
                        $("#"+id).closest("tr").remove();
                    }
                    else
                    {
                        swal({      
                            title: "<?php _el('access_denied', _l('order')); ?>",           
                            type: "error",                            
                        });
                    }  
                }
            });
    });
}

/**
 * Deletes all the selected records when clicked on DELETE SELECTED button
 */
function delete_selected() 
{ 
    var delivery_charge_ids = [];

    $(".checkbox:checked").each(function()
    {
        var id = $(this).attr('id');
        delivery_charge_ids.push(id);
    });
    if (delivery_charge_ids == '')
    {
        jGrowlAlert("<?php _el('select_before_delete_alert', _l('delivery_charge')) ?>", 'danger');
        preventDefault();
    }
    swal({
        title: "<?php _el('multiple_deletion_alert'); ?>",
        text: "<?php _el('multiple_recovery_alert'); ?>",
        type: "warning", 
        showCancelButton: true, 
        cancelButtonText:"<?php _el('no_cancel_it'); ?>",
        confirmButtonText: "<?php _el('yes_i_am_sure'); ?>",        
    },
    function()
    {
        $.ajax({
            url:BASE_URL+'admin/delivery_charge/delete_selected',
            type: 'POST',
            data: {
              ids:delivery_charge_ids
            },
            success: function(msg)
            {
                if (msg=="true")
                {
                    swal({
                        title: "<?php _el('_deleted_successfully', _l('delivery_charge')); ?>",
                        type: "success",
                    });
                    $(delivery_charge_ids).each(function(index, element) 
                    {
                        $("#"+element).closest("tr").remove();
                    });
                }
                else
                {
                  swal({
                        title: "<?php _el('access_denied', _l('delivery_charge')); ?>",            
                        type: "error",                            
                    });
                }
            }
        });
    });
}
</script>
